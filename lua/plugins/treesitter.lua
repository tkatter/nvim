return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        lazy = 'false',
        branch = 'main',
        event = { 'BufReadPost', 'BufNewFile' },
        cmd = { 'TSUpdateSync', 'TSInstall' },
        dependencies = {
            {
                'windwp/nvim-ts-autotag',
                ft = 'html',
                lazy = true,
                opts = {},
            },
        },
        config = function()
            -- Don't call setup for default value:
            -- require('nvim-treesitter').setup {}
            require('nvim-treesitter').install {
                'bash',
                'c',
                'dockerfile',
                'dot',
                'elixir',
                'git_config',
                'git_rebase',
                'gitattributes',
                'gitcommit',
                'heex',
                'html',
                'json',
                'just',
                'lua',
                'luadoc',
                'markdown',
                'markdown_inline',
                'rust',
                'ssh_config',
                'styled',
                'superhtml',
                'toml',
                'vim',
                'vimdoc',
                'yaml',
            }
        end,
    },
}
