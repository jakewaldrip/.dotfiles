-- Remove trailing spaces
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = { '*' },
  command = [[%s/\s\+$//e]],
})

-- Enable closing help/popup windows with q instead of :q
vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = "keymap 'q' to close help/quickfix/netrw/etc windows",
  pattern = 'help,qf,netrw',
  callback = function()
    vim.keymap.set('n', 'q', '<C-w>c', { buffer = true, desc = 'Quit (or Close) help, quickfix, netrw, etc windows' })
  end,
})

-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
