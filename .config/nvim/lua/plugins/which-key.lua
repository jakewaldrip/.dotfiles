-- Which Key, shows pending keybinds
-- https://github.com/folke/which-key.nvim

return {
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  opts = {
    preset = 'helix',
    delay = 0,
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = {},
    },
    spec = {
      -- Top Level
      { '<leader>c',        group = '[C]ursors' },
      { '<leader>u',        group = '[U]tilities' },
      { '<leader>e',        group = '[E]rrors' },
      { '<leader>g',        group = '[G]it' },
      { '<leader>b',        group = '[B]uffer' },
      { '<leader><leader>', hidden = true },
      { '<leader>m',        group = '[M]acros' },
      { '<leader>r',        group = '[R]ename' },
      { '<leader>s',        group = '[S]earch' },
      { '<leader>t',        group = '[T]oggle' },
      { '<leader>a',        group = '[A]i' },

      -- Overrides
      { 'gra',              desc = 'Code [A]ctions' },
      { 'gri',              desc = '[I]mplementation' },
      { 'grr',              desc = '[R]efe[r]ences (Quickfix)' },
      { 'grn',              desc = '[R]e[n]ame (Quickfix)' },
    },
  },
}
