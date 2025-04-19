-- Cyberdream, theme setup

return {
  'scottmckendry/cyberdream.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('cyberdream').setup {
      transparent = true,
      italic_comments = true,
      hide_fillchars = true,
      borderless_pickers = false,
      terminal_colors = true,
      variant = 'default',
    }
    vim.cmd 'colorscheme cyberdream'
  end,
}
