---@class StLineConfig
---@field insert_hl? vim.api.keyset.highlight highlight settings for git insertions.
---@field delete_hl? vim.api.keyset.highlight highlight settings for git deletions.
---@field format? fun(stats: GitStat[]): string function that takes a list of
---[GitStat] to return as a formatted string for display in statusline.

---@class GitStat
---@field hl 'GitIns'|'GitDel'
---@field kind 'insertion'|'deletion'
---@field value number

local api = vim.api
local fs  = vim.fs

---@type StLineConfig
local ST_LINE_DEFAULTS = {
  insert_hl = { link = 'OkMsg'    , default = true },
  delete_hl = { link = 'ErrorMsg' , default = true },
  format = function(git_stats)
    return vim
      .iter(git_stats)
      :map(function(stat)
        return string.format(
          '%%#%s#%s%d%%*',
          stat.hl,
          stat.kind == 'insertion' and '+' or '-',
          stat.value
        )
      end):join(' ')
  end
}

local M = {}
local Opt = vim.deepcopy(ST_LINE_DEFAULTS)

---@type integer The namespace used by st_line
M._ns = api.nvim_create_namespace('st_line')

---@param opts StLineConfig|nil options for st_line
M.setup = function(opts)
  Opt = vim.tbl_deep_extend('force', ST_LINE_DEFAULTS, opts or {})
  api.nvim_set_hl(M._ns, 'GitIns', Opt.insert_hl)
  api.nvim_set_hl(M._ns, 'GitDel', Opt.delete_hl)
  api.nvim_set_hl_ns(M._ns)


  if fs.root(vim.env.PWD, '.git') then
    local winnr = api.nvim_get_current_win()
    M.git_status(winnr, vim.env.PWD)
  end

  api.nvim_create_autocmd({'BufEnter', 'BufWinEnter', 'BufWritePost'}, {
    callback = function(ev)
      if vim.uv.fs_stat(ev.file) and fs.root(ev.buf, '.git') then
          local winnr = api.nvim_get_current_win()
          local path = fs.abspath(ev.file)
          M.git_status(winnr, fs.dirname(path))
      end
    end
  })
end

---@param obj vim.SystemCompleted
---@return string
---Parses the output of `git diff --shortstat` into a list of [GitStat].
---
---Calls [StLineConfig.format()] with the list if set, otherwise returns a
---string in the format '%%#GitIns#%s%d%%* %%#GitDel#%s%d%%*' where '%s' is
---either +/- and '%d' corresponds to the number of insertions or deletions.
---
---If `obj.code > 0` or `obj.stdout` is empty, then this will return an empty string.
local function parse_git_diff(obj)
  if obj.code > 0 or obj.stdout == '' then
    return ''
  end

  local df_stat = vim.split(obj.stdout, ',', { trimempty = true })
  local stats   = vim.list_slice(df_stat, 2)

  local git_stats = vim
    .iter(stats)
    :map(function(v)
      local num, sign = string.match(v, '(%d+)%s%a+%(([%+%-])%)')
      local n = tonumber(num)
      if sign == '+' then
        return { hl = 'GitIns', kind = 'insertion', value = n }
      else
        return { hl = 'GitDel', kind = 'insertion', value = n }
      end
    end)

  if Opt.format then
    return Opt.format(git_stats:totable())
  else
    return ST_LINE_DEFAULTS.format(git_stats:totable())
  end
end

---@param winnr integer Window to set the w.git_status variable for.
---@param path string Directory for which to run `git diff --shortstat` from.
---Sets w[[winnr]].git_status = '+<INS> -<DEL>', or the string returned from
---[StLineConfig.format()] if configured, for the git directory at `path`.
M.git_status = function(winnr, path)
  local ok, res = pcall(function()
    return vim.system(
      { 'git', 'diff', '--shortstat' },
      { cwd = path, text = true }
    ):wait()
  end)

  if ok then
    vim.w[winnr].git_status = parse_git_diff(res)
  else
    vim.w[winnr].git_status = ''
  end
end

return M
