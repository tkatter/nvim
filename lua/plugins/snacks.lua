return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@diagnostic disable-next-line: undefined-doc-name
    ---@type snacks.Config
    opts = {
        notifier = {
            enabled = true,
            timeout = 8000, -- Duration in milliseconds
            sort = { 'level', 'added' },
            level = vim.log.levels.TRACE,
            icons = {
                trace = 'ﯓ',
                debug = '',
                info = '',
                warn = '',
                error = '',
            },
            top_down = true,
            refresh = 100, -- Refresh interval in milliseconds
            padding = true,
            margin = { top = 0, right = 1, bottom = 0 },
        },
        input = { enabled = true },
        rename = { enabled = true },
    },
}
