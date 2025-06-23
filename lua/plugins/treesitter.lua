return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = { 'BufReadPost', 'BufNewFile' },
        dependencies = {
            {
                'windwp/nvim-ts-autotag',
                event = 'VeryLazy',
                opts = {},
            },
            'nvim-treesitter/nvim-treesitter-textobjects',
            'JoosepAlviste/nvim-ts-context-commentstring',
        },
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = {
                    'bash',
                    'css',
                    'dockerfile',
                    'dot',
                    'git_config',
                    'git_rebase',
                    'gitattributes',
                    'gitcommit',
                    'html',
                    'javascript',
                    'jsdoc',
                    'json',
                    'lua',
                    'luadoc',
                    'markdown',
                    'markdown_inline',
                    'rust',
                    'scss',
                    'ssh_config',
                    'styled',
                    'superhtml',
                    'toml',
                    'tsx',
                    'typescript',
                    'vim',
                    'vimdoc',
                    'yaml',
                },
                auto_install = true,
                highlight = {
                    enable = true,
                    disable = function(lang, buf)
                        _ = lang
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                    additional_vim_regex_highlighting = false,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<Enter>',
                        node_incremental = '<Enter>',
                        scope_incremental = 'grc',
                        node_decremental = '<Backspace>',
                    },
                },
            }
        end,
    },
}
