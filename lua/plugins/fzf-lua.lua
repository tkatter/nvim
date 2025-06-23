return {
    'ibhagwan/fzf-lua',
    -- dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- or if using mini.icons/mini.nvim
    dependencies = { 'echasnovski/mini.icons' },
    opts = {
        winopts = {
            border = 'double',
            title_pos = 'center',
            preview = {
                border = 'double',
            },
        },
        defaults = {
            file_icons = 'mini',
        },
    },
    keys = {
        { '<leader>fh', '<cmd>FzfLua helptags<cr>', desc = 'Find help' },
        { '<leader>fb', '<cmd>FzfLua builtin<cr>', desc = 'Find fzf builtins' },
        { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find files' },
        { 'ga', '<cmd>FzfLua live_grep<cr>', desc = 'Grep project' },
        { 'gb', '<cmd>FzfLua lgrep_curbuf<cr>', desc = 'Grep current buffer' },
        { 'gw', '<cmd>FzfLua grep_cword<cr>', desc = 'Grep word under cursor' },
        { 'gW', '<cmd>FzfLua grep_cWORD<cr>', desc = 'Grep WORD under cursor' },
        { '<leader>fd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Find document diagnostics' },
        { '<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>', desc = 'Find document symbols' },
        { '<leader>fS', '<cmd>FzfLua lsp_live_workspace_symbols<cr>', desc = 'Find workspace symbols' },
        { 'gca', '<cmd>FzfLua lsp_code_actions<cr>', desc = 'Code actions' },
    },

    -- Registers fzf with vim.ui.select
    -- removes annoying notifications from snacks.nvim
    init = function()
        require('fzf-lua').register_ui_select()
    end,
}
