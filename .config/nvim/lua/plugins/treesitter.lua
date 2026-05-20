-- Treesitter
-- Highlight, edit, and navigate code

return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = 'main',
  build = ':TSUpdate'
}
