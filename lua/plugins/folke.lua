return {
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        lazy = true,
        opts = {
            lsp = {
                progress = { enabled = false },
                hover = { enabled = false },
                message = { enabled = false },
                signature = { enabled = false },
                documentation = { enabled = false },
            },
            notify = { enabled = false },
            markdown = { enabled = false },
        },
        dependencies = {
            'MunifTanjim/nui.nvim',
        },
    },
    {
        'folke/todo-comments.nvim',
        event = { 'VeryLazy', 'BufRead' },
        lazy = true,
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {},
    },
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
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
    },
    {
        'folke/which-key.nvim',
        lazy = true,
        opts = {
            preset = 'modern',
            triggers = {
                { '<leader>', mode = { 'n', 'v' } },
            },
            spec = {
                { 'gs', group = 'surround' },
                { '<leader>b', group = 'buffer' },
                { '<leader>t', group = 'tab' },
                { '<leader>f', group = 'file' },
                { '<leader>w', group = 'window' },
                { 'g', group = 'edit' },
                { 'z', group = 'folds' },
                { '[', group = 'previous' },
                { ']', group = 'next' },
            },
            win = {
                wo = {
                    winblend = 20,
                },
            },
            keys = {
                scroll_down = '<Down>',
                scroll_up = '<Up>',
            },
        },

        keys = {
            {
                '<leader>?',
                function()
                    require('which-key').show { global = false }
                end,
                desc = 'Buffer Local Keymaps (which-key)',
            },
        },
    },
}
