-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Rename word under cursor using substitute command
vim.keymap.set('n', '<leader>rw', ':%s/<C-r><C-w>/', { desc = '[R]ename [W]ord' })

vim.keymap.set('n', '<leader>ee', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>eq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- System Clipboard interactions
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y',
  { noremap = true, silent = true, desc = '[y]ank selection to system clipboard' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>Y', '"+yy',
  { noremap = true, silent = true, desc = '[Y]ank line to system clipboard' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p',
  { noremap = true, silent = true, desc = '[p]aste to system clipboard' })

-- Swap ; and :
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', ':', ';')

-- Toggle Relative Line Numbers
vim.keymap.set('n', '<leader>tr', ':set invrelativenumber<CR>', { desc = '[T]oggle [R]elative Line Numbers' })

-- Copy whole file
vim.keymap.set('n', '<leader>by', 'ggvG$y', { desc = '[B]uffer [y]ank' })
vim.keymap.set('n', '<leader>bY', 'ggvG$"+y', { desc = '[B]uffer [Y]ank' })

-- Paste whole file
vim.keymap.set('n', '<leader>bp', 'ggvG$p', { desc = '[B]uffer [p]aste' })
vim.keymap.set('n', '<leader>bP', 'ggvG$"+p', { desc = '[B]uffer [P]aste' })
