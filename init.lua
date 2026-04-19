-- Add ~/.local/share/nvim to rtp
vim.opt.rtp:prepend(vim.fn.stdpath('data'))

local api  = vim.api
local diag = vim.diagnostic
local fn   = vim.fn
local map  = vim.keymap
local ts   = vim.treesitter

---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
local imap  = function(rhs, lhs, opts)
  map.set({'i'}, rhs, lhs, opts or {})
end

---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
local vmap  = function(rhs, lhs, opts)
  map.set({'v'}, rhs, lhs, opts or {})
end

---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
local nmap  = function(rhs, lhs, opts)
  map.set({'n'}, rhs, lhs, opts or {})
end

---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
local tmap  = function(rhs, lhs, opts)
  map.set({'t'}, rhs, lhs, opts or {})
end

vim.o.ch  = 1
vim.o.sw  = 2
vim.o.et  = true
vim.o.tgc = true
vim.o.cc  = "80"
vim.o.nu  = true
vim.o.rnu = true
vim.o.scs = true
vim.o.clipboard  = 'unnamedplus'
vim.o.statusline = "%<%f[%n] %h%w%m%r%15.(%{% get(w:, 'git_status', '') %}%)%=%y %L %-8.(%l:%v%)"
vim.o.pumborder  = 'rounded'
vim.o.winborder  = 'rounded'

vim.cmd [[
  let g:netrw_usetab  = 1
  let g:netrw_winsize = 30 
  let g:netrw_size_style   = 'H'
  let g:netrw_browse_split = 3
  let mapleader    = ' '
  let session_file = stdpath('state') .. '/session.vim'
  colorscheme catppuccin
  hi link NormalFloat MsgArea
  hi link FloatBorder MatchParen
  hi link PmenuBorder MatchParen
  hi @function.builtin.just guifg=#eba0ac
  hi @function.builtin.bash guifg=#f38ba8
  "Highlighting on yank actions (from :h vim.hl)
  autocmd TextYankPost * silent! lua vim.hl.on_yank { higroup='Visual' }
  "Auto-completion menu
  "see ':h ins-completion-menu' for details on customization
  set completeopt=menuone,noselect,popup
]]

require 'st_line'.setup()
require 'lsp.lua_ls'
require 'lsp.rust'
require 'diagnostics'
require 'align'

-- UI2
local ui2  = require('vim._core.ui2')
local msgs = require('vim._core.ui2.messages')
ui2.enable({
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
      height  = 0.5,
    },
    dialog = {
      height  = 0.5,
    },
    msg = {
      height  = 0.3,
      timeout = 3000,
    },
    pager = {
      height  = 0.5,
    },
  },
})

-- Notification/toasts
local orig_set_pos = msgs.set_pos
msgs.set_pos = function(tgt)
  orig_set_pos(tgt)
  if (tgt == 'msg' or tgt == nil)
  and api.nvim_win_is_valid(ui2.wins.msg) then
    pcall(api.nvim_win_set_config, ui2.wins.msg, {
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
nmap('<C-s>', '<esc>:w<cr>',   { desc = 'Quick :w' })
vmap('<C-s>', '<esc>:w<cr>gv', { desc = 'Quick :w' })

-- Terminal things
tmap('<C-Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
tmap('<C-R>', "'<C-\\><C-N>\"'.nr2char(getchar()).'pi'",
  { expr = true, desc = 'Paste from register' })

-- Ntree as mini.files
nmap('<leader>e', function()
  local buf = api.nvim_get_current_buf()
  local dir = vim.fs.dirname(fn.expand('#' .. buf .. ':p'))
  vim.cmd('Hexplore ' .. dir)
end, { desc = 'Open netrw file browser for current buffer\'s directory' })

-- Restart && restore nvim session
nmap("<leader>re", function()
  vim.cmd [[
    exe 'mks! ' .. fnameescape(g:session_file)
    exe 'restart source ' .. fnameescape(g:session_file)
  ]]
end, { silent = true, desc = "Restart nvim session" })

-- Manual trigger for LSP completion
imap('<c-space>', function() vim.lsp.completion.get() end,
  { desc = 'Manual poll for LSP completion' })

local augp    = api.nvim_create_augroup('tkatter', { clear = true })
local augp_ts = api.nvim_create_augroup('tkatter/ts', { clear = true })
local augp_rnu = api.nvim_create_augroup('tkatter/toggle_rnu', { clear = true })

-- Treesitter/Diagnostics for sh/bash scripts
api.nvim_create_autocmd('FileType', {
  group    = augp_ts,
  desc     = 'Treesitter and diagnostics for shell scripts',
  pattern  = {'sh', 'bash'},
  callback = function(ev)
    if ts.language.add('bash') then
      ts.start(ev.buf, 'bash')
    end

    if fn.executable('shellcheck') == 0 then
      return
    end

    vim.cmd [[
      setlocal makeprg=shellcheck\ -f\ gcc\ %
      setlocal shellpipe=2>&1\ >
    ]]

    -- NOTE: prior to #35330 `buf` was `buffer`
    -- So on neovim v0.12-0.12.1 and lower use `buffer`
    -- https://github.com/neovim/neovim/pull/35330

    -- Turn ':make' results into diagnostics from shellcheck
    local ns = api.nvim_create_namespace('shellcheck')
    api.nvim_create_autocmd('QuickFixCmdPost', {
      buf      = ev.buf,
      callback = function()
        local qf    = fn.getqflist()
        local diags = diag.fromqflist(qf)
        diag.set(ns, ev.buf, diags)
        fn.setqflist({}, 'r')
      end
    })

    api.nvim_create_autocmd('BufWritePost', {
      buf     = ev.buf,
      command = 'silent make',
    })

    -- Hacky BufEnter
    -- call shellcheck after all the setup on initial
    -- entry to populate diagnostics (if any)
    vim.cmd 'silent make'
  end
})

-- Treesitter startup
api.nvim_create_autocmd('FileType', {
  group    = augp_ts,
  desc     = 'Start treesitter',
  pattern  = {'just', 'rust', 'python', 'javascript'},
  callback = function(ev)
    if ts.language.add(ev.match) then
      ts.start(ev.buf, ev.match)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end
})

-- Quick close non-editing windows
api.nvim_create_autocmd('FileType', {
  group    = augp,
  desc     = 'Close with <q>',
  pattern  = { 'git', 'help', 'netrw', 'man', 'qf', 'scratch' },
  callback = function(args)
    if args.match == 'netrw' then
      vim.keymap.set('n', 'q', '<C-W>q',        { buffer = args.buf })
    else
      vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = args.buf })
    end
  end,
})

-- Toggle relative line numbers
api.nvim_create_autocmd({
    'BufEnter',
    'FocusGained',
    'InsertLeave',
    'CmdlineLeave',
    'WinEnter',
  }, {
  group    = augp_rnu,
  desc     = 'Toggle relative line numbers on',
  callback = function(_)
    if vim.wo.nu and
    not vim.startswith(api.nvim_get_mode().mode, 'i') then
      vim.wo.relativenumber = true
    end
  end,
})

api.nvim_create_autocmd({
    'BufLeave',
    'FocusLost',
    'InsertEnter',
    'CmdlineEnter',
    'WinLeave'
  }, {
  group    = augp_rnu,
  desc     = 'Toggle relative line numbers off',
  callback = function(_)
    if vim.wo.nu then
      vim.wo.relativenumber = false
    end
  end,
})
