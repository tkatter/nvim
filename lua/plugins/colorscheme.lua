-- https://catbbrew.com/design
return {
    'catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    priority = 1000,
    opts = {
        integrations = {
            aerial = true,
            alpha = true,
            blink_cmp = true,
            cmp = true,
            dashboard = true,
            flash = true,
            fzf = true,
            grug_far = true,
            gitsigns = true,
            headlines = true,
            illuminate = true,
            indent_blankline = { enabled = true },
            leap = true,
            lsp_trouble = true,
            mason = true,
            markdown = true,
            mini = true,
            native_lsp = {
                enabled = true,
                underlines = {
                    errors = { 'undercurl' },
                    hints = { 'undercurl' },
                    warnings = { 'undercurl' },
                    information = { 'undercurl' },
                },
            },
            navic = { enabled = true, custom_bg = 'lualine' },
            neotest = true,
            neotree = true,
            noice = true,
            notify = true,
            semantic_tokens = true,
            snacks = true,
            telescope = true,
            treesitter = true,
            treesitter_context = true,
            which_key = true,
        },
        flavour = 'mocha', -- mocha, macchiato, frappe, latte,
        -- color_overrides = {
        --     mocha = {
        --         base = '#141420',
        --         mantle = '#191929',
        --         overlay0 = '#9f9f9f',
        --         mauve = '#aa8cff',
        --         peach = '#ff795e',
        --         yellow = '#f7e38f',
        --         blue = '#33a4ff',
        --         teal = '#72cffd',
        --         green = '#9ffbc2',
        --         text = '#f1a5bc',
        --         -- blue = '#FFFFFF',
        --         -- crust = '#666666',
        --     },
        -- },
    },
    specs = {
        {
            'akinsho/bufferline.nvim',
            optional = true,
            opts = function(_, opts)
                if (vim.g.colors_name or ''):find 'catppuccin' then
                    opts.highlights = require('catppuccin.groups.integrations.bufferline').get()
                end
            end,
        },
    },
    -- This actually calls the colorscheme.
    config = function(_, opts)
        require('catppuccin').setup(opts)
        vim.cmd.colorscheme 'catppuccin'
    end,
}
