vim.lsp.config('postgres_lsp', {
    cmd = { 'postgres-language-server', 'lsp-proxy' },
    filetypes = {
        'sql',
    },
    root_markers = { 'postgres-language-server.jsonc' },
})

vim.lsp.enable 'postgres_lsp'
