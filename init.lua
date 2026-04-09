-- Add ~/.local/share/nvim to rtp
vim.opt.rtp:prepend(vim.fn.stdpath('data'))

vim.g.mapleader = ' '

-- TABS
vim.opt.sw = 2
vim.opt.et = true

-- COLORS
vim.opt.termguicolors = true
vim.opt.colorcolumn   = "80"
vim.cmd('colorscheme catppuccin')
-- Highlighting on yank actions (from :h vim.hl)
vim.cmd([[
  autocmd TextYankPost * silent! lua vim.hl.on_yank {higroup='Visual'}
]])

-- LINE NUMBERS 
-- TODO: make function to only use rel when in editing buffer
vim.opt.nu  = false
vim.opt.rnu = true

-- CLIPBOARD
vim.opt.clipboard='unnamedplus'

-- UI2
require('vim._core.ui2').enable({
  enable = true, -- Whether to enable or disable the UI.
  msg = { -- Options related to the message module.
    ---@type 'cmd'|'msg' Default message target, either in the
    ---cmdline or in a separate ephemeral message window.
    ---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
    ---or table mapping |ui-messages| kinds and triggers to a target.
    targets = 'cmd',
    cmd = { -- Options related to messages in the cmdline window.
      height = 0.5 -- Maximum height while expanded for messages beyond 'cmdheight'.
    },
    dialog = { -- Options related to dialog window.
      height = 0.5, -- Maximum height.
    },
    msg = { -- Options related to msg window.
      height = 0.5, -- Maximum height.
      timeout = 5000, -- Time a message is visible in the message window.
    },
    pager = { -- Options related to message window.
      height = 1, -- Maximum height.
    },
  },
})

require 'lsp.rust'
require 'lsp.lua_ls'
require 'diagnostics'
require 'align'

vim.keymap.set('i', '<c-space>', function()
  vim.lsp.completion.get()
end)
