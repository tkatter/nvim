return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
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
}
