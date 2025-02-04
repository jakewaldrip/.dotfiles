-- test value
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- Disable netrw by default (fooling vim into thinking it's already loaded)
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Preview Window Taller
vim.opt.previewheight = 22

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- 2 Space Tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Disable folding when opening file
vim.wo.foldenable = false

-- [[ Basic Keymaps ]]
-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Custom Commands
vim.api.nvim_create_user_command('Cppath', function()
  local path = vim.fn.expand '%:p'
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

-- Enable folding
vim.api.nvim_create_autocmd({ 'FileType' }, {
  callback = function()
    if require('nvim-treesitter.parsers').has_parser() then
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    else
      vim.opt.foldmethod = 'syntax'
    end
  end,
})

-- Gives rounded border to LSP pop ups
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'double' })
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'double' })
    vim.diagnostic.config {
      float = {
        border = 'double',
      },
    }
  end,
})

-- Remove trailing spaces
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = { '*' },
  command = [[%s/\s\+$//e]],
})

-- Open config
vim.keymap.set('n', '<leader>nc', ':e ~/.config/nvim/init.lua<CR>', { desc = '[C]onfiguration open (init.lua)', silent = true })

-- Format via eslint
vim.keymap.set('n', '<leader>nf', ':EslintFixAll<CR>', { desc = '[F]ormat File (Eslint)', silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Yanky Keybindings
vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
vim.keymap.set({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)')
vim.keymap.set({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)')

vim.keymap.set('n', '<c-p>', '<Plug>(YankyPreviousEntry)')
vim.keymap.set('n', '<c-n>', '<Plug>(YankyNextEntry)')

-- System Clipboard interactions
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank selection to system clipboard' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to system clipboard' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste to system clipboard' })

-- Swap ; and :
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', ':', ';')

-- Toggle Relative Line Numbers
vim.keymap.set('n', '<leader>tr', ':set invrelativenumber<CR>', { desc = '[T]oggle [R]elative Line Numbers' })

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

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Visualize Git Conflicts and add keymaps
  { 'rhysd/conflict-marker.vim' },

  { -- Smooth Scroll
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup()
    end,
  },

  { -- Next line maintains indentation
    'vidocqh/auto-indent.nvim',
    opts = {},
  },

  { -- Improved yanking behavior
    'gbprod/yanky.nvim',
    opts = {},
  },

  { 'AndreM222/copilot-lualine' },

  -- Included plugins
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  { import = 'custom.plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
