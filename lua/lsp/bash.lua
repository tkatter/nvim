vim.lsp.config('bashls', {
    cmd = { 'bash-language-server', 'start' },
    settings = {
        bashIde = {
            -- Prevent recursive scanning which will cause issues when opening a file
            -- directly in the home directory (e.g. ~/foo.sh).
            -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
            globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
        },
    },
    filetypes = { 'bash', 'sh' },
    root_markers = { '.git' },
})
