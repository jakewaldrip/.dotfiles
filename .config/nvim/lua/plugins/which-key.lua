-- Which Key, shows pending keybinds
-- https://github.com/folke/which-key.nvim

return {
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  opts = {
    delay = 0,
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = {},
    },
    spec = {
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>e', group = '[E]rrors' },
      { '<leader>m', group = '[M]acros' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>n', group = '[N]ew' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { '<leader>a', group = '[A]i' },
    },
  },
}
