-- Add ~/.local/share/nvim to rtp
vim.opt.rtp:prepend(vim.fn.stdpath('data'))

vim.o.ch  = 1
vim.o.sw  = 2
vim.o.et  = true
vim.o.tgc = true
vim.o.cc  = "80"
vim.o.nu  = false
vim.o.rnu = true
vim.o.scs = true
vim.g.mapleader  = ' '
vim.o.clipboard  = 'unnamedplus'
vim.o.statusline = "%<%f[%n] %h%w%m%r%15.(%{% get(w:, 'git_status', '') %}%)%=%y %L %-8.(%l:%v%)"

vim.cmd('colorscheme catppuccin')

-- Highlighting on yank actions (from :h vim.hl)
vim.cmd([[
  autocmd TextYankPost * silent! lua vim.hl.on_yank { higroup='Visual' }
]])

require'st_line'.setup()
require 'lsp.lua_ls'
require 'lsp.rust'
require 'diagnostics'
require 'align'

-- UI2
require('vim._core.ui2').enable({
  enable = true,
  msg = {
    targets = {
      ['']         = 'msg',
      bufwrite     = 'msg',
      completion   = 'cmd',
      confirm      = 'cmd',
      echo         = 'msg',
      echoerr      = 'pager',
      echomsg      = 'msg',
      empty        = 'cmd',
      emsg         = 'pager',
      list_cmd     = 'pager',
      lua_error    = 'pager',
      lua_print    = 'msg',
      progress     = 'pager',
      quickfix     = 'msg',
      rpc_error    = 'pager',
      search_cmd   = 'cmd',
      search_count = 'cmd',
      shell_cmd    = 'pager',
      shell_err    = 'pager',
      shell_out    = 'pager',
      shell_ret    = 'msg',
      undo         = 'msg',
      verbose      = 'pager',
      wildlist     = 'cmd',
      wmsg         = 'msg',
    },
    cmd = {
      height = 0.5,
    },
    dialog = {
      height = 0.5,
    },
    msg = {
      height = 0.3,
      timeout = 3000,
    },
    pager = {
      height = 0.5,
    },
  },
})

local ui2 = require('vim._core.ui2')
local msgs = require('vim._core.ui2.messages')
local orig_set_pos = msgs.set_pos
msgs.set_pos = function(tgt)
  orig_set_pos(tgt)
  if (tgt == 'msg' or tgt == nil) and vim.api.nvim_win_is_valid(ui2.wins.msg) then
    pcall(vim.api.nvim_win_set_config, ui2.wins.msg, {
      anchor   = 'NE',
      border   = 'rounded',
      col      = vim.o.columns - 1,
      relative = 'editor',
      row      = 1,
      style    = 'minimal',
    })
  end
end
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
    local ns = vim.api.nvim_create_namespace('shellcheck')
    vim.api.nvim_create_autocmd('QuickFixCmdPost', {
      buf = ev.buf,
      -- buffer = ev.buf,
      callback = function()
        local qf = vim.fn.getqflist()
        local diags = vim.diagnostic.fromqflist(qf)
        vim.diagnostic.set(ns, ev.buf, diags)
        vim.fn.setqflist({}, 'r')
      end
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      buf = ev.buf,
      -- buffer = ev.buf,
      command = 'silent make',
    })

    -- Hacky BufEnter
    -- call shellcheck after all the setup on initial
    -- entry to populate diagnostics (if any)
    vim.cmd('silent make')
  end
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'just', 'rust'},
  callback = function(ev)
    if vim.treesitter.language.add(ev.match) then
      vim.treesitter.start(ev.buf, ev.match)
    end
  end
})
