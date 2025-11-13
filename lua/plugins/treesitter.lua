return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
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
            require('nvim-treesitter.configs').setup {
                ensure_installed = {
                    'bash',
                    'dockerfile',
                    'dot',
                    'elixir',
                    'heex',
                    'git_config',
                    'git_rebase',
                    'gitattributes',
                    'gitcommit',
                    'html',
                    'json',
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
