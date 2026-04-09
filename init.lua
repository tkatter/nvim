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
  autocmd TextYankPost * silent! lua vim.hl.on_yank { higroup='Visual' }
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

require 'lsp.lua_ls'
require 'lsp.rust'
require 'diagnostics'
require 'align'

-- CTRL_s speed-save
vim.keymap.set({'i', 'v', 'n'}, '<C-s>', '<esc>:w<cr>')

-- haven't figured out how to get this to work
vim.keymap.set('i', '<c-space>', function()
  vim.lsp.completion.get()
end)

-- Treesitter/Diagnostics for sh/bash scripts
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'sh', 'bash'},
  callback = function(ev)
    if vim.treesitter.language.add('bash') then
      vim.treesitter.start(ev.buf, 'bash')
    end

    vim.cmd([[
      setlocal makeprg=shellcheck\ -f\ gcc\ %
      setlocal shellpipe=2>&1\ >
    ]])

  -- NOTE: prior to #35330 `buf` was `buffer`
  -- So on neovim v0.12-0.12.1 and lower use `buffer`
  -- https://github.com/neovim/neovim/pull/35330

  -- Turn ':make' results into diagnostics from shellcheck
  local ns = vim.api.nvim_create_namespace("shellcheck")
  vim.api.nvim_create_autocmd('QuickFixCmdPost', {
    -- buf = ev.buf,
    buffer = ev.buf,
    callback = function()
      local qf = vim.fn.getqflist()
      local diags = vim.diagnostic.fromqflist(qf)
      vim.diagnostic.set(ns, ev.buf, diags)
      vim.fn.setqflist({}, 'r')
    end
  })

  vim.api.nvim_create_autocmd('BufWritePost', {
    -- buf = ev.buf,
    buffer = ev.buf,
    command = 'make',
  })

  -- Hacky BufEnter
  -- call shellcheck after all the setup on initial
  -- entry to populate diagnostics (if any)
  vim.cmd('make')
  end
})
