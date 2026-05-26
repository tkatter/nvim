local api = vim.api

---Set 'visual' mode keymap.
---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
local nmap  = function(rhs, lhs, opts)
 vim.keymap.set({'n'}, rhs, lhs, opts or {})
end

---Set 'visual' mode keymap.
---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
local vmap  = function(rhs, lhs, opts)
 vim.keymap.set({'v'}, rhs, lhs, opts or {})
end

---@class TagConfig
---@field keymaps KeymapConf
---@field max_height number Maximum window height for the taglist

---@class KeymapConf
---@field get_tag_visual string RHS binding for keybind in visual mode
---@field get_tag_normal string RHS binding for keybind in normal mode
---@field open_taglist string RHS binding for opening the taglist
---@field cycle_next_tag string RHS binding for cycling through the tags
---@field jump string RHS binding for the jump keybind when in the taglist buffer

---@type TagConfig
local TAG_DEFAULTS = {
  max_height = 10,
  keymaps = {
    get_tag_visual = '<leader>gt',
    get_tag_normal = '<leader>gt',
    open_taglist = '<leader>to',
    cycle_next_tag = '<leader>tn',
    jump = '<Cr>',
  }
}

---@class TagEntry
---@field file string File of the match
---@field row number Row of the match
---@field col number Column of the match
---@field out number Contents of the line that matched the current tag

local M = {}
local Opt = vim.deepcopy(TAG_DEFAULTS)

---@type number|nil Autocmd ID state for removal when closing taglist
M.aucmd = nil

---@type TagEntry[]|nil List of tag entries
M.taglist = {}

---@type string|nil Current tag term
M.current_tag = nil

---@type number|nil Current tag index in taglist
M.current_tag_idx = nil

---@type number|nil Window ID of the preview window
M.preview_win = nil

---@type number|nil Window ID of the taglist window
M.taglist_win = nil

---@type number|nil Buffer ID of the taglist buffer
M.taglist_buf = nil

---Setup the plugin with keymaps and validate requirements (ripgrep).
---
---Defined visual and normal mode keymaps for generating, cycling, and opening
---the taglist.
---@param opts TagConfig Configuration options
function M.setup(opts)
  if vim.fn.executable('rg') == 0 then
    vim.notify('ripgrep not found', vim.log.levels.ERROR)
    return
  end

  Opt = vim.tbl_deep_extend('force', TAG_DEFAULTS, opts or {})
  local maps = Opt.keymaps

  nmap(maps.cycle_next_tag, function()
    if not M.is_empty() then
      if M.current_tag_idx + 1 > #M.taglist then
        M.current_tag_idx = 1
      else
        M.current_tag_idx = M.current_tag_idx + 1
      end

      M.open_tag()
    end
  end, { desc = 'Cycle through tags' })

  nmap(maps.open_taglist, function()
    if not M.is_empty() then M.create_tag_win() end
  end, { desc = 'Open taglist window' })

  vmap(maps.get_tag_visual, '<Esc>:lua require("tags").get_visual()<Cr>',
  { desc = 'Generate taglist from selection' })

  nmap(maps.get_tag_normal, function()
    M.current_tag = vim.fn.expand('<cword>')
    M.generate_taglist()

    if M.taglist_buf then
      api.nvim_buf_delete(M.taglist_buf, { force = true })
    end

    M.create_tag_win()
  end, { desc = 'Generate taglist from cword' })
end

---Create the taglist window/buffer.
---
---This function assumes that `M.taglist` has already been set, and will return
---otherwise. If the buffer already exists, this will return early; call
---`M.close_if_open()` first.
---
---This will create a keymap within the taglist buffer that will jump to the
---selected tag on <CR>. Upon buffer or window close/deletion, there is an autocmd
---that will cleanup internal state.
function M.create_tag_win()
  if M.is_empty() then
    vim.notify('taglist is empty', vim.log.levels.INFO)
    return
  end

  if M.aucmd or M.taglist_win or M.taglist_buf then
    vim.notify('taglist already open', vim.log.levels.WARN)
    return
  end

  M.preview_win = api.nvim_get_current_win()
  local saved_split_setting = vim.opt.splitbelow:get()

  -- create taglist split
  vim.o.splitbelow = true
  api.nvim_cmd({
    cmd = 'new',
    range = { #M.taglist },
  }, {})
  M.taglist_win = api.nvim_get_current_win()

  -- hacky ensure we are in the new window
  if M.taglist_win == M.preview_win then
    api.nvim_cmd({
      cmd = 'wincmd',
      args = { 'j' },
    }, {})
    M.taglist_win = api.nvim_get_current_win()
  end

  vim.o.splitbelow = saved_split_setting

  -- create a new scratch buffer
  M.taglist_buf = api.nvim_create_buf(false, true)
  api.nvim_set_option_value('bufhidden', 'wipe',    {buf = M.taglist_buf})
  api.nvim_set_option_value('buftype',   'nofile',  {buf = M.taglist_buf})
  api.nvim_set_option_value('swapfile',  false,     {buf = M.taglist_buf})
  api.nvim_set_option_value('modeline',  false,     {buf = M.taglist_buf})
  api.nvim_set_option_value('filetype',  'taglist', {buf = M.taglist_buf})

  -- populate window and lines
  api.nvim_win_set_buf(M.taglist_win, M.taglist_buf)
  api.nvim_buf_set_lines(M.taglist_buf, 0, -1, false, M.taglist_to_lines())
  api.nvim_win_set_cursor(M.taglist_win, {1, 0})

  -- ensure non-listed and not modifiable
  api.nvim_set_option_value('buflisted', false,  {buf = M.taglist_buf})
  api.nvim_set_option_value('modifiable', false, {buf = M.taglist_buf})

  -- clamp taglist window height
  if #M.taglist > Opt.max_height then
    api.nvim_win_set_height(M.taglist_win, Opt.max_height)
  end

  -- highlight matches of current_tag
  api.nvim_cmd({
    cmd = 'syntax',
    args = { 'match', 'tagMatch', 'display', string.format('%q', M.current_tag) }
  }, {})

  -- set buffer local jump keymap
  api.nvim_buf_set_keymap(M.taglist_buf, 'n', Opt.keymaps.jump, '', {
    desc = 'Jump to tag',
    callback = function()
      local idx = api.nvim_win_get_cursor(M.taglist_win)[1]
      M.current_tag_idx = idx
      M.open_tag()
    end
  })

  -- cleanup state with autocmd on bufwipe
  M.aucmd = api.nvim_create_autocmd({'BufWipeout'}, {
    buf = M.taglist_buf,
    once = true,
    callback = function(ev)
      if not ev.buf == M.taglist_buf then
        return
      end

      api.nvim_cmd({
        cmd = 'syntax',
        args = { 'clear', 'tagMatch' }
      }, {})

      pcall(api.nvim_del_autocmd, M.aucmd)

      M.aucmd = nil
      M.taglist_win = nil
      M.taglist_buf = nil
    end
  })
end

---@param line string Line of output from ripgrep
---@return TagEntry tag
local parse_tag_entry = function(line)
  -- match: filepath:line:col:rest
  local file, row, col, out = line:match('^(.-):(%d+):(%d+):(.*)$')
  out = out:gsub("^%s+", "") -- trim whitespace from start
  return { file = file, row = tonumber(row), col = tonumber(col), out = out }
end

---Populates `M.taglist` with entries. Assumes that `M.current_tag` has been set.
---
---Generate the taglist by running ripgrep in the buffer directory (if available)
---or current working directory. If no results were found or ripgrep failed, sets
---`M.taglist` to `nil`.
function M.generate_taglist()
  local buf = api.nvim_get_current_buf()
  local bufname = api.nvim_buf_get_name(buf)
  local dir = nil
  if vim.uv.fs_stat(bufname) then
    local bufpath = vim.fs.abspath(bufname)
    dir = vim.fs.dirname(bufpath)
  end

  local run_grep = function(work_dir)
    local opts = { text = true }
    if work_dir then opts.cwd = work_dir end
    return vim.system({ 'rg', '--vimgrep', '-F', M.current_tag }, opts):wait()
  end

  local ok, res = pcall(run_grep, dir)

  if ok then
    if res.code > 0 or res.stdout == '' then
      M.taglist = nil
      return
    end

    M.taglist = vim
      .iter(vim.split(res.stdout, '\n', { trimempty = true }))
      :map(parse_tag_entry):totable()

    if #M.taglist > 0 then
      M.current_tag_idx = 1
    end
  else
    M.taglist = nil
  end
end

--- Convert the internal taglist to display lines for the taglist buffer.
--- @return string[] tags Array of lines to show in taglist buffer
function M.taglist_to_lines()
  if M.is_empty() then return {''} end

  return vim
    .iter(M.taglist)
    :map(function(tag)
      return string.format("%s: %s", tag.file, tag.out)
    end):totable()
end

---Open the currently-selected tag entry in a window.
---
---Opens the file in the window that was open when first opening the tag list.
---If that window is no longer available or the taglist is the only open window,
---creates a split. Moves cursor to the tag location and recenters the view.
function M.open_tag()
  if M.current_tag_idx and M.taglist[M.current_tag_idx] == nil then
    vim.notify('open_tag(): invalid tag index', vim.log.levels.WARN)
    return
  end

  local tag = M.taglist[M.current_tag_idx]

  if M.preview_win and api.nvim_win_is_valid(M.preview_win) then
    api.nvim_set_current_win(M.preview_win)
    api.nvim_cmd({
      cmd = 'edit',
      args = { vim.fn.fnameescape(tag.file) }
    }, {})
    api.nvim_win_set_cursor(M.preview_win, {tag.row, tag.col - 1})
  else
    local win = api.nvim_get_current_win()
    local saved_split_setting = vim.opt.splitbelow:get()

    if win == M.taglist_win then
      vim.o.splitbelow = false
    else
      vim.o.splitbelow = true
    end

    api.nvim_cmd({
      cmd = 'split',
      args = { vim.fn.fnameescape(tag.file) }
    }, {})

    M.preview_win = api.nvim_get_current_win()
    api.nvim_win_set_cursor(M.preview_win, {tag.row, tag.col - 1})

    vim.o.splitbelow = saved_split_setting
  end

  -- after opening file in win, bring it to center
  api.nvim_cmd({
    cmd = 'normal',
    bang = true,
    args = { 'zz' }
  }, {})
end

---Check whether the taglist is empty or nil
---@return boolean
function M.is_empty()
  if not M.taglist or next(M.taglist) == nil then
    return true
  else
    return false
  end
end

---Closes the taglist buffer if it is open.
---
---The autocmd that is created when the buffer is initially created will cleanup
---state on 'BufWipeout'; resetting `M.aucmd`, `M.taglist_win`, and `M.taglist_buf`.
function M.close_if_open()
  if M.taglist_buf then
    api.nvim_buf_delete(M.taglist_buf, { force = true })
  end
end

---Generate a taglist from the the most recent selection and open the taglist buffer.
---
---This reads '<' and '>' marks, hence the choice of 'most recent selection' words.
---This will not handle multi-line visual selections.
function M.get_visual()
  local buf = api.nvim_get_current_buf()
  local s = api.nvim_buf_get_mark(buf, "<")
  local e = api.nvim_buf_get_mark(buf, ">")

  if not s[1] == e[1] then
    vim.notify('multi-line selections are not allowed', vim.log.levels.WARN)
    return
  end

  M.current_tag = api.nvim_buf_get_text(buf, s[1] - 1, s[2], e[1] - 1, e[2] + 1, {})[1]
  M.generate_taglist()
  M.close_if_open()
  M.create_tag_win()
end

return M
