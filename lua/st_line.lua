local M = {}

---@type integer The namespace used by st_line
M._ns = vim.api.nvim_create_namespace('st_line')

M.setup = function()
  vim.api.nvim_set_hl(M._ns, 'GitIns', {link = 'OkMsg', default = true})
  vim.api.nvim_set_hl(M._ns, 'GitDel', {link = 'ErrorMsg', default = true})
  vim.api.nvim_set_hl_ns(M._ns)


  if vim.fs.root(vim.env.PWD, '.git') then
    local winnr = vim.api.nvim_get_current_win()
    M.git_status(winnr, vim.env.PWD)
  end

  vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter', 'BufWritePost'}, {
    callback = function(ev)
      if vim.uv.fs_stat(ev.file) and vim.fs.root(ev.buf, '.git') then
          local winnr = vim.api.nvim_get_current_win()
          local path = vim.fs.abspath(ev.file)
          M.git_status(winnr, vim.fs.dirname(path))
      end
    end
  })
end

---@param obj vim.SystemCompleted
--parses the output of `git diff --shortstat` into a highlighted string of the
--format '%%#GitIns#%s%d%%* %%#GitDel#%s%d%%*' where '%s' is either +/- and '%d'
--corresponds to the number of insertions or deletions.
--
--if obj.code > 0 or obj.stdout is empty, then this will return an empty string.
local function parse_git_diff(obj)
  if obj.code > 0 or obj.stdout == '' then
    return ''
  end

  local hl = ''
  local diff_stats = vim.split(obj.stdout, ',', {trimempty = true})
  local stats = vim.list_slice(diff_stats, 2)
  local it = vim.iter(stats):map(function(v)
    local num, sign = string.match(v, '(%d+)%s%a+%(([%+%-])%)')
    if sign == '+' then
      hl = '%#GitIns#'
    else
      hl = '%#GitDel#'
    end
    return string.format('%s%s%d%%*', hl, sign, num)
  end)

  return it:join(' ')
end

---@param winnr integer window to set the w.git_status variable for
---@param path string directory for which to run `git diff --shortstat` from
--sets w\[winnr\].git_status = '+<INS> -<DEL>' for the git directory at `path`
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
