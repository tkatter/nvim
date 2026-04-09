vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = vim.api.nvim_create_augroup('my_elixir_formatter', { clear = true }),
    pattern = { '*.ex', '*.exs' },
    callback = function()
        vim.cmd 'MixFormat'
    end,
    desc = 'formats elixir files on save with `mix format <file>`.',
})

vim.api.nvim_create_user_command('MixFormat', function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    local path = vim.fn.fnamemodify(buf_name, ':p')
    local mix_cmd = '!mix format ' .. path
    vim.cmd(mix_cmd)
end, {})
