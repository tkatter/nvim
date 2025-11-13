vim.g.projects_dir = vim.env.HOME .. '/Code'

-- Install Lazy.
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    }
end

vim.opt.rtp:prepend(lazypath)

---@type LazySpec
local plugins = 'plugins'

-- General setup (order matters)
require 'settings'
require 'keymaps'
require 'commands'
require 'autocmds'
require 'winbar'
require 'marks'
require 'lsp'

require('lazy').setup(plugins, {
    install = {
        -- Do not automatically install on startup
        -- Set to true and restart nvim as needed
        missing = false,
        colorscheme = { 'colorscheme' },
    },
    change_detection = {
        -- automatically check for config file changes and reload the ui
        enabled = true,
        notify = true, -- get a notification when changes are found
    },
    -- So far no plugins use luarocks
    rocks = {
        enabled = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                'gzip',
                'netrwPlugin',
                'rplugin',
                'tarPlugin',
                'tohtml',
                'tutor',
                'zipPlugin',
            },
        },
    },
})
