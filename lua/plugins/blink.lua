return {

--    {
--        'zbirenbaum/copilot.lua',
--        cmd = 'Copilot',
--        event = 'InsertEnter',
--        opts = {
--            suggestion = { enabled = false },
--            panel = { enabled = false },
--            filetypes = {
--                yaml = true,
--                markdown = true,
--                javascript = true,
--                typescript = true,
--                rust = true,
--                css = true,
--                html = true,
--                json = true,
--                lua = true,
--            },
--            workspace_folders = {
--                '/home/thomas/Code/Local',
--                '/home/thomas/Code/Projects',
--            },
--        },
--    },

    {
        'saghen/blink.cmp',
        dependencies = {
            'rafamadriz/friendly-snippets',
            'fang2hou/blink-copilot',
        },

        -- use a release tag to download pre-built binaries
        version = '1.*',

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = { preset = 'default' },

            appearance = {
                nerd_font_variant = 'mono',
            },

            signature = { enabled = true },
            completion = {

                list = { selection = { preselect = false, auto_insert = false } },
                documentation = { auto_show = true },

                menu = { auto_show = true },
                ghost_text = { enabled = true },
            },
            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
--			'copilot'
--                providers = {
--                    copilot = {
--                        name = 'copilot',
--                        module = 'blink-copilot',
--                        score_offset = 100,
--                        async = true,
--                    },
--                },
            },
            fuzzy = { implementation = 'prefer_rust_with_warning' },
        },
        opts_extend = { 'sources.default' },
    },
}
