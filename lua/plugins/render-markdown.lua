return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
    ft = 'markdown',
    lazy = true,
    opts = {
        completions = { blink = { enabled = true } },
    },
    config = function(_, opts)
        require('render-markdown').setup(opts)
    end,
}
