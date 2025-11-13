return {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    lazy = true,
    dependencies = {
        'rafamadriz/friendly-snippets',
    },

    -- use a release tag to download pre-built binaries
    -- need to build from source on FreeBSD
    version = '1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
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
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
}
