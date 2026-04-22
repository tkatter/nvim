local api  = vim.api
local diag = vim.diagnostic
local fn   = vim.fn
local map  = vim.keymap
local ts   = vim.treesitter

---@param grp string
---@param opts vim.api.keyset.highlight|nil
---Set global highlights (ns = 0).
local ghl = function(grp, opts)
  api.nvim_set_hl(0, grp, opts or {})
end

---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
---Set 'insert' mode keymap.
local imap  = function(rhs, lhs, opts)
  map.set({'i'}, rhs, lhs, opts or {})
end

---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
---Set 'visual' mode keymap.
local vmap  = function(rhs, lhs, opts)
  map.set({'v'}, rhs, lhs, opts or {})
end

---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
---Set 'normal' mode keymap.
local nmap  = function(rhs, lhs, opts)
  map.set({'n'}, rhs, lhs, opts or {})
end

---@param rhs string
---@param lhs fun()|string
---@param opts vim.keymap.set.Opts|nil
---Set 'terminal' mode keymap.
local tmap  = function(rhs, lhs, opts)
  map.set({'t'}, rhs, lhs, opts or {})
end

local function init()
  require 'ui2'
  require 'diagnostics'
  require 'align'
  vim.lsp.enable 'rust'
  vim.lsp.enable 'lua_ls'
  vim.lsp.enable 'clangd'
end

-- Add ~/.local/share/nvim to rtp
vim.opt.rtp:prepend(fn.stdpath('data'))

vim.o.ch  = 1
vim.o.sw  = 2
vim.o.et  = true
vim.o.tgc = true
vim.o.cc  = "80"
vim.o.nu  = true
vim.o.rnu = true
vim.o.scs = true
vim.o.clipboard    = 'unnamedplus'
vim.o.statusline   = "%<%f[%n] %h%w%m%r%15.(%{% get(w:, 'git_status', '') %}%)%=%y %L %-8.(%l:%v%)"
vim.o.pumheight    = 10
vim.o.pumblend     = 15
vim.o.pumborder    = 'rounded'
vim.o.winborder    = 'rounded'
vim.o.autocomplete = true
vim.o.complete     = '.^5,w^5,b^5,u^5'
vim.o.completeopt  = 'menuone,noselect,popup' -- ':h ins-completion-menu'

vim.g.mapleader     = ' '
vim.g.session_file  = fn.stdpath('state') .. '/session.vim'
vim.g.netrw_winsize = 30
vim.g.netrw_size_style   = 'H'
vim.g.netrw_browse_split = 3

vim.cmd.colorscheme 'catppuccin'

ghl('NormalFloat', { bg = '#181825', update = true })
ghl('FloatBorder', { fg = '#fab387', bg = '#181825' })
ghl('PmenuBorder', { fg = '#fab387', bg = '#181825' })
ghl('@function.builtin.just', { fg = '#eba0ac', update = true })
ghl('@function.builtin.bash', { fg = '#f38ba8', update = true })

ghl('Pmenu', {
  fg = '#cba6f7',
  update = true,
})

ghl('PmenuMatch', {
  fg = '#b4befe',
  update = true,
})

ghl('PmenuSel', {
  blend = 0,
  update = true
})

ghl('PmenuKindSel', {
  fg = '#fab387',
  bg = '#181825',
  bold = true,
  update = true,
})

ghl('PmenuKind', {
  fg = '#f9e2af',
  bg = '#181825',
  bold = true,
  update = true,
})

-- Highlighting on yank actions (from :h vim.hl)
api.nvim_create_autocmd('TextYankPost',
  { command = 'silent! lua vim.hl.on_yank { higroup="Visual" }' })

-- CTRL_s speed-save
nmap('<C-s>', '<esc>:w<cr>',   { desc = 'Quick :w' })
vmap('<C-s>', '<esc>:w<cr>gv', { desc = 'Quick :w' })

-- Terminal things
tmap('<C-Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
tmap('<C-R>', "'<C-\\><C-N>\"'.nr2char(getchar()).'pi'",
  { expr = true, desc = 'Paste from register' })

-- MiniFiles file explorer
nmap(
  '<leader>e',
  '<cmd>lua MiniFiles.open()<cr>',
  { desc = 'Open MiniFiles file browser' }
)

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
      -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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

-- Make a scratch buffer
api.nvim_create_user_command('Scratch', function()
    vim.cmd 'bel 30new'
    local buf = vim.api.nvim_get_current_buf()
    for name, value in pairs {
        filetype = 'scratch',
        buftype = 'nofile',
        bufhidden = 'wipe',
        swapfile = false,
        modifiable = true,
    } do
        vim.api.nvim_set_option_value(name, value, { buf = buf })
    end
end, { desc = 'Open a scratch buffer', nargs = 0 })

init()
