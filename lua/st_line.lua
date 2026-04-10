local M = {}

M.setup = function()
  local ns = vim.api.nvim_create_namespace('st_line')
  vim.api.nvim_set_hl(ns, 'GitIns', {link = 'OkMsg'})
  vim.api.nvim_set_hl(ns, 'GitDel', {link = 'ErrorMsg'})
  vim.api.nvim_set_hl_ns(ns)

  vim.w.git_status = ""

  if vim.fs.root(vim.env.PWD, '.git') then
    local winnr = vim.api.nvim_get_current_win()
    M.git_status(winnr, vim.env.PWD)
  end

  vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter', 'BufWritePost'}, {
    callback = function(ev)
      if vim.fs.root(ev.buf, '.git') then
        local winnr = vim.api.nvim_get_current_win()
        local path = vim.fs.abspath(ev.file)
        M.git_status(winnr, vim.fs.dirname(path))
      end
    end
  })
end

local function parse_git_diff(obj)
  if obj.code > 0 or obj.stdout == '' then
    return ''
  end

  local stats = vim.split(obj.stdout, ',', {trimempty = true})
  local ins, del = stats[#stats - 1], stats[#stats]
  local pat = '(%d+)%s%a+%(([%+%-])%)'
  local m1, m12 = string.match(ins, pat)
  local m2, m22 = string.match(del, pat)
  local res = string.format('%%#GitIns#%s%d%%* %%#GitDel#%s%d%%*', m12, m1, m22, m2)
  return res
end

---@param winnr integer
---@param path string
M.git_status = function(winnr, path)
  local res = vim.system({'git', 'diff', '--shortstat'}, {
    cwd = path,
    text = true,
  }):wait()

  vim.w[winnr].git_status = parse_git_diff(res)
end

return M
