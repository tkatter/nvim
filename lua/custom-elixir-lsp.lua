local elixir = require 'elixir'
-- local elixirls = require "elixir.elixirls"

local M = {}

M.setup = function()
    elixir.setup {
        nextls = { enable = false },
        elixirls = {
            enable = true,
            on_attach = function()
                vim.keymap.set('n', '<space>fp', ':ElixirFromPipe<cr>', { buffer = true, noremap = true })
                vim.keymap.set('n', '<space>tp', ':ElixirToPipe<cr>', { buffer = true, noremap = true })
                vim.keymap.set('v', '<space>em', ':ElixirExpandMacro<cr>', { buffer = true, noremap = true })
            end,
        },
        projectionist = { enable = false },
    }
end

return M

-- return {
--     'elixir-tools/elixir-tools.nvim',
--     version = '*',
--     event = { 'BufReadPre', 'BufNewFile' },
--     config = function()
--         local elixir = require 'elixir'
--         local elixirls = require 'elixir.elixirls'
--
--         vim.api.nvim_create_user_command('ElixirOutputPanel', function()
--             elixirls.open_output_panel { window = 'vsplit' }
--         end, {})
--
--         elixir.setup {
--             nextls = { enable = false },
--             elixirls = {
--                 enable = true,
--                 settings = elixirls.settings {
--                     dialyzerEnabled = true,
--                     enableTestLenses = false,
--                 },
--                 on_attach = function(client, bufnr)
--                     vim.keymap.set('n', '<space>fp', ':ElixirFromPipe<cr>', { buffer = true, noremap = true })
--                     vim.keymap.set('n', '<space>tp', ':ElixirToPipe<cr>', { buffer = true, noremap = true })
--                     vim.keymap.set('v', '<space>em', ':ElixirExpandMacro<cr>', { buffer = true, noremap = true })
--                 end,
--             },
--             projectionist = {
--                 enable = true,
--             },
--         }
--     end,
--     dependencies = {
--         'nvim-lua/plenary.nvim',
--     },
-- }
