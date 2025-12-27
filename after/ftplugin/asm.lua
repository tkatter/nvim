local asm_group = vim.api.nvim_create_augroup('asm-formatter', { clear = true })

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = asm_group,
    pattern = '*.asm',
    callback = function()
        vim.o.sw = 6
        vim.o.ts = 6
        vim.o.expandtab = false
    end,
})

-- vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
--     group = asm_group,
--     pattern = '*.asm',
--     callback = function()
--         vim.cmd 'AsmFmt'
--     end,
--     desc = 'formats asm files on save with `asmfmt -w <file>`.',
-- })
--
-- vim.api.nvim_create_user_command('AsmFmt', function()
--     local buf_name = vim.api.nvim_buf_get_name(0)
--     local file_dir = vim.fn.fnamemodify(buf_name, ':p:h')
--     local file_name = vim.fn.fnamemodify(buf_name, ':p:t')
--     local on_exit = function(obj)
--         print(obj.code)
--         print(obj.signal)
--         print(obj.stdout)
--         print(obj.stderr)
--     end
--
--     -- Runs asynchronously:
--     -- vim.system({ 'asmfmt', '-w', file_name }, { cwd = file_dir }, on_exit)
--
--     -- Runs synchronously:
--     local _ = vim.system({ 'asmfmt', '-w', file_name }, { cwd = file_dir }):wait()
--     -- { code = 0, signal = 0, stdout = 'hello\n', stderr = '' }
-- end, {})
