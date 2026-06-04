-- Treesitter
-- Highlight, edit, and navigate code

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  opts = {
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  }
}
