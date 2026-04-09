local cwd = vim.fn.getcwd()
local special_dir = "/Volumes/school"
vim.g.projects_dir = vim.env.HOME .. "/code"
vim.g.school_dir = special_dir .. "/obsidian"

if cwd:find(vim.pesc(special_dir), 1, true) == 1 then
  require 'settings'
  require 'keymaps'
  require 'commands'
  require 'autocmds'
  require 'winbar'
  require 'marks'

  vim.opt.colorcolumn="80"
  vim.opt.tgc=true

  -- vim.api.nvim_create_autocmd('FileType', {
  --   pattern = { 'c' },
  --   callback = function()
  --     vim.opt.shiftwidth=4
  --     vim.treesitter.start()
  --     vim.api.nvim_set_hl(0, '@function.c', {
  --       fg = "#f5c2e7",
  --     })
  --   end
  -- })

  -- vim.api.nvim_create_autocmd('FileType', {
  --   pattern = { 'markdown' },
  --   callback = function()
  --     vim.opt.formatprg="fmt 72"
  --     vim.treesitter.start()
  --     vim.api.nvim_set_hl(0, 'Title', {
  --       fg = "LightMagenta",
  --       bold = true,
  --     })
  --     vim.api.nvim_set_hl(0, '@constant.bash', {
  --       fg = "#94e2d5",
  --     })
  --     vim.api.nvim_set_hl(0, '@markup.raw.block.markdown', {
  --       fg = "#f9e2af",
  --     })
  --     vim.api.nvim_set_hl(0, 'Function', {
  --       fg = "#f5c2e7",
  --     })
  --     vim.api.nvim_set_hl(0, '@markup.strong', {
  --       fg = "LightBlue",
  --       bold = true,
  --     })
  --     vim.api.nvim_set_hl(0, '@markup.italic', {
  --       fg = "LightGreen",
  --       italic = true,
  --     })
  --   end
  -- })

  return
end


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
