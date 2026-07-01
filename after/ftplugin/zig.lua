local api = vim.api

-- zig style guide states line length of 100
vim.o.cc = "100"
vim.o.tw =  100
vim.g.zig_build_run    = false
vim.g.zig_fmt_autosave = 0

vim.o.makeprg     = "zig build --summary none --error-style minimal $*"
vim.o.shellpipe   = "&>"
vim.o.errorformat = "%E%>%f:%l:%c: error: %m,%Z%m,%>%f:%l:%c: %trror: %m"

api.nvim_create_autocmd('QuickFixCmdPre', {
  pattern = "make",
  callback = function()
    if not vim.g.zig_build_run then
      vim.notify("building...", vim.log.levels.INFO)
      vim.g.zig_build_run = true
    end
  end
})

api.nvim_create_autocmd('QuickFixCmdPost', {
  pattern = "make",
  callback = function()
    vim.g.zig_build_run = false
    local qflist = vim.fn.getqflist()
    local filtered = {}

    for _, item in ipairs(qflist) do
      if item.valid ~= 0 then
        table.insert(filtered, item)
      end
    end

    vim.fn.setqflist({}, 'r', {
      items = filtered,
      title = 'Zig Build Errors',
    })

    -- Auto-open the QuickFix list:
    api.nvim_cmd({ cmd = 'cw' }, {})
  end
})
