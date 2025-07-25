return {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
    },
    init = function()
        local config = require 'nvim-treesitter.configs'
        config.setup {
            textobjects = {
                swap = {
                    enable = true,
                    swap_next = {
                        ['<leader>s'] = '@parameter.inner',
                    },
                    swap_previous = {
                        ['<leader>S'] = '@parameter.inner',
                    },
                },
                select = {
                    enable = true,
                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ['af'] = { query = '@function.outer', desc = 'Select around function' },
                        ['if'] = { query = '@function.inner', desc = 'Select inner function' },
                        ['ac'] = { query = '@class.outer', desc = 'Select around class' },
                        ['ci'] = { query = '@comment.inner', desc = 'Select inner comment' },
                        ['co'] = { query = '@comment.outer', desc = 'Select around comment' },
                        -- You can optionally set descriptions to the mappings (used in the desc parameter of
                        -- nvim_buf_set_keymap) which plugins like which-key display
                        ['ic'] = { query = '@class.inner', desc = 'Select inner class' },
                        -- You can also use captures from other query groups like `locals.scm`
                        ['as'] = { query = '@local.scope', query_group = 'locals', desc = 'Select language scope' },
                    },
                    -- You can choose the select mode (default is charwise 'v')
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * method: eg 'v' or 'o'
                    -- and should return the mode ('v', 'V', or '<c-v>') or a table
                    -- mapping query_strings to modes.
                    selection_modes = {
                        ['@parameter.outer'] = 'v', -- charwise
                        ['@function.outer'] = 'V', -- linewise
                        ['@class.outer'] = '<c-v>', -- blockwise
                    },
                    -- If you set this to `true` (default is `false`) then any textobject is
                    -- extended to include preceding or succeeding whitespace. Succeeding
                    -- whitespace has priority in order to act similarly to eg the built-in
                    -- `ap`.
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * selection_mode: eg 'v'
                    -- and should return true or false
                    include_surrounding_whitespace = true,
                },
            },
        }
    end,
}
