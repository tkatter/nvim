return {
    'folke/noice.nvim',
    event = 'VeryLazy',
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
        presets = {
            -- command_palette = true,
        },
    },
    dependencies = {
        'MunifTanjim/nui.nvim',
    },
}
