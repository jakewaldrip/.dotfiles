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
      overrides = function(colours)
        return {
          TelescopePromptPrefix = { fg = colours.blue },
          TelescopeMatching = { fg = colours.cyan },
          TelescopeResultsTitle = { fg = colours.blue },
          TelescopePromptCounter = { fg = colours.cyan },
          TelescopePromptTitle = { fg = colours.bg, bg = colours.blue, bold = true },
        }
      end,
    }
    vim.cmd 'colorscheme cyberdream'
  end,
}
