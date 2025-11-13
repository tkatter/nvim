return {
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        lazy = true,
        opts = function()
            return {
                icons_enabled = true,
                theme = 'auto',
                sections = {
                    lualine_a = {
                        'mode',
                        {
                            'lsp_status',
                            ignore_lsp = { 'copilot' },
                        },
                    },
                    lualine_b = { 'branch', 'diff', { 'buffers', hide_filename_extension = true } },
                    lualine_c = {
                        { 'filename', file_status = true, path = 4, shorting_target = 40 },
                        'diagnostics',
                        'searchcount',
                    },
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'location', 'progress' },
                    lualine_z = {
                        {
                            'datetime',
                            style = '%H:%M',
                        },
                    },
                },
            }
        end,
    },
    {
        'akinsho/bufferline.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons', -- Icons for bufferline.
            'echasnovski/mini.bufremove', -- Buffer removal functionality.
        },
        event = 'VeryLazy',
        lazy = true,
        opts = {
            options = {
                show_close_icon = true,
                show_buffer_close_icons = true,
                truncate_names = false,
                indicator = { style = 'underline' },
                close_command = function(bufnr)
                    require('mini.bufremove').delete(bufnr, false)
                end,
                diagnostics = 'nvim_lsp',
                diagnostics_indicator = function(_, _, diag)
                    local icons = require('icons').diagnostics
                    local indicator = (diag.error and icons.ERROR .. ' ' or '') .. (diag.warning and icons.WARN or '')
                    return vim.trim(indicator)
                end,
                separator_style = 'slant',
            },
        },
        keys = {
            -- Buffer navigation.
            { '<leader>bp', '<cmd>BufferLinePick<cr>', desc = 'Pick a buffer to open' },
            { '<leader>bc', '<cmd>BufferLinePickClose<cr>', desc = 'Select a buffer to close' },
            { '<leader>bl', '<cmd>BufferLineCloseLeft<cr>', desc = 'Close buffers to the left' },
            { '<leader>br', '<cmd>BufferLineCloseRight<cr>', desc = 'Close buffers to the right' },
            { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close other buffers' },
        },
    },
}
