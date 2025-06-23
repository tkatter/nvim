-- Remap for dealing with word wrap and adding jumps to the jumplist.
vim.keymap.set('n', 'j', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']], { expr = true })
vim.keymap.set('n', 'k', [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']], { expr = true })

-- Keeping the cursor centered.
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll downwards' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll upwards' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next result' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous result' })

-- Indent while remaining in visual mode.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Formatting.
vim.keymap.set('n', 'gQ', 'mzgggqG`z<cmd>delmarks z<cr>zz', { desc = 'Format buffer' })
vim.keymap.set('n', '<leader>cf', function()
    require('conform').format { lsp_format = 'fallback', timeout_ms = 500 }
end, { desc = 'Format code (conform)' })

-- Open the package manager.
vim.keymap.set('n', '<leader>L', '<cmd>Lazy<cr>', { desc = 'Lazy' })

-- Buffer management.
vim.keymap.set('n', '<leader>bd', '<cmd>bd<cr>', { desc = 'Delete current buffer' })
vim.keymap.set('n', 'L', '<cmd>bN<cr>', { desc = 'Go to next buffer' })
vim.keymap.set('n', 'H', '<cmd>bp<cr>', { desc = 'Go to previous buffer' })

-- Window management.
-- Move between windows.
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to the left window', remap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to the bottom window', remap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to the top window', remap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to the right window', remap = true })

-- Create and close windows.
vim.keymap.set('n', '<leader>wn', '<cmd>rightb vnew<cr>', { desc = 'New window', remap = true })
vim.keymap.set('n', '<leader>wx', '<cmd>clo<cr>', { desc = 'Close current window', remap = true })

-- Move windows.
vim.keymap.set('n', '<A-R>', '<C-W>r', { desc = 'Rotate windows', remap = true })
vim.keymap.set('n', '<A-K>', '<C-W>K', { desc = 'Move window top', remap = true })
vim.keymap.set('n', '<A-J>', '<C-W>J', { desc = 'Move window bottom', remap = true })
vim.keymap.set('n', '<A-H>', '<C-W>H', { desc = 'Move window left', remap = true })
vim.keymap.set('n', '<A-L>', '<C-W>L', { desc = 'Move window right', remap = true })

-- Tab navigation.
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = 'Close tab page' })
vim.keymap.set('n', '<leader>tn', '<cmd>tab split<cr>', { desc = 'New tab page' })
vim.keymap.set('n', '<leader>to', '<cmd>tabonly<cr>', { desc = 'Close other tab pages' })
vim.keymap.set('n', '<leader>tt', '<cmd>tabnext<cr>', { desc = 'Close other tab pages' })

-- Poweful <esc>.
-- vim.keymap.set({ 'i', 's', 'n' }, '<esc>', function()
-- if require('luasnip').expand_or_jumpable() then
-- require('luasnip').unlink_current()
-- end
-- vim.cmd 'noh'
-- return '<esc>'
-- end, { desc = 'Escape, clear hlsearch, and stop snippet session', expr = true })

-- Make U opposite to u.
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })

-- Escape and save changes.
vim.keymap.set({ 's', 'i', 'n', 'v' }, '<C-s>', '<esc>:w<cr>', { desc = 'Exit insert mode and save changes' })
vim.keymap.set({ 's', 'i', 'n', 'v' }, '<C-S-s>', function()
    vim.g.skip_formatting = true
    return '<esc>:w<cr>'
end, { desc = 'Exit insert mode and save changes (without formatting)', expr = true })

-- Quickly go to the end of the line while in insert mode.
vim.keymap.set({ 'i', 'c' }, '<C-l>', '<C-o>A', { desc = 'Go to the end of the line' })

-- Floating terminal.
vim.keymap.set({ 'n', 't' }, '<leader>T', function()
    require('float_term').float_term('bash', { cwd = vim.fn.expand '%:p:h' })
end, { desc = 'Toggle floating terminal' })

-- Mark management.
vim.keymap.set('c', 'dm', 'delmarks', { desc = 'Delete marks' })

-- Yank line in visual mode.
vim.keymap.set('v', 'Y', [[:<C-u>let @+=join(getline("'<", "'>"), "\n")<cr>]], { desc = 'Yank line(s) to clipboard' })
