-- Blink completion (nvim-cmp replacement)
-- https://github.com/Saghen/blink.cmp

return {
  'saghen/blink.cmp',
  lazy = false, -- lazy loading handled internally
  version = 'v0.*', -- use a release tag to download pre-built binaries
  opts = {
    nerd_font_variant = 'mono',

    accept = { auto_brackets = { enabled = true } },
    trigger = { signature_help = { enabled = true } },

    keymap = { preset = 'enter' },

    windows = {
      autocomplete = {
        min_width = 20,
        max_width = 40,
        max_height = 15,
        border = 'rounded',
        scrolloff = 2,
        direction_priority = { 's', 'n' },
      },
      documentation = {
        min_width = 15,
        max_width = 50,
        max_height = 20,
        border = 'rounded',
        direction_priority = {
          autocomplete_north = { 'e', 'w', 'n', 's' },
          autocomplete_south = { 'e', 'w', 's', 'n' },
        },
      },
    },

    sources = {
      completion = {
        enabled_providers = { 'lsp', 'path', 'snippets', 'buffer', 'dadbod' },
      },
      providers = {
        dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
      },
    },
  },
}
