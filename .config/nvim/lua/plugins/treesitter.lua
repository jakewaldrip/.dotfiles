-- Treesitter
-- Highlight, edit, and navigate code

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'typescript', 'tsx' },
    auto_install = true,
    highlight = {
      enable = true,
      --  If you are experiencing weird indenting issues, add the language to these two lists
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
  end,
}
