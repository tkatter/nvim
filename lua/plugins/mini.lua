local set_mark = function(id, path, desc)
    MiniFiles.set_bookmark(id, path, { desc = desc })
end

local function join_paths(...)
    local segments = { ... }
    -- Join segments with '/', which Neovim will normalize
    local path_str = table.concat(segments, '/')
    -- Use fnamemodify with 's' to "shell" normalize the path.
    -- This handles things like redundant slashes and converting / to \ on Windows.
    return vim.fn.fnamemodify(path_str, ':s')
end

local set_source_dir = function(path)
    local src_path = join_paths(path, 'src')

    -- print('Source path:', src_path)
    local path_is_dir = function(path2)
        local stat = vim.loop.fs_stat(path2)

        -- Check if path exists
        if not stat then
            return false
        end

        -- Check if path is a directory
        return stat.type == 'directory'
    end

    if path_is_dir(src_path) then
        return src_path
    else
        return path
    end
end

return {
    {
        'echasnovski/mini.icons',
        lazy = true,
        config = function()
            require('mini.icons').setup()
        end,
    },
    {
        'echasnovski/mini.files',
        dependencies = {
            'echasnovski/mini.icons', -- Icons for mini.files.
        },
        lazy = true,
        keys = {
            {
                '<leader>e',
                function()
                    local bufname = vim.api.nvim_buf_get_name(0)
                    local dir_path = vim.fn.fnamemodify(bufname, ':p:h')
                    if dir_path and vim.uv.fs_stat(dir_path) then
                        vim.g.current_working_dir = dir_path
                        require('mini.files').open(dir_path, false)
                    end
                end,
                desc = 'Open Mini Files',
            },
        },
        opts = {
            mappings = {
                show_help = '?',
                go_in_plus = '<cr>',
                go_out_plus = '<tab>',
            },
            windows = { preview = true, width_focus = 50, width_nofocus = 15, width_preview = 70 },
            options = { permanent_delete = true, use_as_default_explorer = true },
        },
        config = function(_, opts)
            local minifiles = require 'mini.files'
            minifiles.setup(opts)

            -- Keep track of when the explorer is open to disable format on save.
            local minifiles_explorer_group = vim.api.nvim_create_augroup('tkatter/minifiles_explorer', { clear = true })
            vim.api.nvim_create_autocmd('User', {
                group = minifiles_explorer_group,
                pattern = 'MiniFilesExplorerOpen',
                callback = function()
                    vim.g.minifiles_active = true
                end,
            })
            vim.api.nvim_create_autocmd('User', {
                group = minifiles_explorer_group,
                pattern = 'MiniFilesExplorerClose',
                callback = function()
                    vim.g.minifiles_active = false
                end,
            })
            vim.api.nvim_create_autocmd('User', {
                group = minifiles_explorer_group,
                pattern = 'MiniFilesWindowOpen',
                callback = function(args)
                    local win_id = args.data.win_id

                    -- Customize window-local settings
                    vim.wo[win_id].winblend = 20
                    local config = vim.api.nvim_win_get_config(win_id)
                    config.border, config.title_pos = 'double', 'right'
                    vim.api.nvim_win_set_config(win_id, config)
                end,
            })
            vim.api.nvim_create_autocmd('User', {
                pattern = 'MiniFilesExplorerOpen',
                callback = function()
                    set_mark('c', vim.fn.stdpath 'config', 'Config') -- path
                    set_mark('w', vim.fn.getcwd(), 'Working directory') -- callable
                    set_mark('~', vim.fn.expand(vim.env.HOME), 'Home directory')
                    set_mark('.', set_source_dir(vim.fn.getcwd()), 'Src directory')
                end,
            })
        end,
    },
}
