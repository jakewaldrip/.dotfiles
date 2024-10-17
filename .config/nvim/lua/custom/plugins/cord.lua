-- Cord, discord status integration for Neovim (written in Rust)
-- https://github.com/vyfor/cord.nvim

return {
  'vyfor/cord.nvim',
  build = './build || .\\build',
  event = 'VeryLazy',
  opts = {}, -- calls require('cord').setup()
}
