-- Lazydev, updates lua LSP to be neovim config aware
-- https://github.com/folke/lazydev.nvim

return {
  'folke/lazydev.nvim',
  ft = 'lua', -- only load on lua files
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  },
}
