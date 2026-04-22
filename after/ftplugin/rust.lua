vim.g.cargo_makeprg_params = 'check -q --message-format short'

local api = vim.api

local gr = api.nvim_create_augroup('hl-comments', { clear = true })
local ns = api.nvim_create_namespace('hl-comments')

api.nvim_set_hl(ns, 'Todo',   { fg = '#1e1e2e', bg = '#89dceb', bold = true })
api.nvim_set_hl(ns, 'Safety', { fg = '#1e1e2e', bg = '#f9e2af', bold = true })
api.nvim_set_hl(ns, 'Note',   { fg = '#1e1e2e', bg = '#cba6f7', bold = true })
api.nvim_set_hl_ns(ns)

---@param stdout string
---@param bufnr number
local function set_marks(stdout, bufnr)
  local hl
  for s in vim.gsplit(stdout, '\n', { trimempty = true }) do
    local line, col, match = string.match(s, '^(%d+):(%d+):(.*)')
    local end_col = col + string.len(match)

    if match:match '[Ss][Aa][Ff][Ee][Tt][Yy]' then
      hl = 'Safety'
    end

    if match:match '[Nn][Oo][Tt][Ee]' then
      hl = 'Note'
    end

    if match:match '[Tt][Oo][Dd][Oo]' then
      hl = 'Todo'
    end

    api.nvim_buf_set_extmark(bufnr, ns, line - 1, col - 1, {
      end_row = line - 1,
      end_col = end_col - 1,
      invalidate = true,
      undo_restore = true,
      hl_group = hl,
    })
  end
end

api.nvim_create_autocmd({
    'BufEnter',
    'BufWritePost',
  }, {
    group    = gr,
    pattern  = '*.rs',
    callback = function(ev)
      if not ev.file then
        return
      end
      local ok, res = pcall(function()
        local file = vim.fn.fnamemodify(ev.file, ':p')
        return vim.system(
          { 'rg', '-I', '-i', '-o', '--column',
            '-e', '\\bTODO\\b:',
            '-e', '\\bSAFETY\\b:',
            '-e', '\\bNOTE\\b:',
            file },
          { text = true }
        ):wait()
      end)

      if not ok
      or res.code < 0
      or res.code > 0
      or res.stdout == '' then
        return
      end

      set_marks(res.stdout, ev.buf)
    end
})
