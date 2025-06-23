-- Global variables. (linux)
vim.g.projects_dir = vim.env.HOME .. '/Code'
vim.g.local_projects = vim.g.projects_dir .. '/Local'
vim.g.main_projects = vim.g.projects_dir .. '/Projects'

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
-- require 'todos'

require('lazy').setup(plugins, {
    ui = { border = 'rounded' },
    dev = { path = vim.g.projects_dir },
    install = {
        -- Do not automatically install on startup
        missing = true,
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
-- Enable new expirimental command-line features.
-- require('vim._extui').enable {}
