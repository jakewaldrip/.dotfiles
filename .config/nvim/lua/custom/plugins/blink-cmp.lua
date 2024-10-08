-- Blink completion (nvim-cmp replacement)
-- https://github.com/Saghen/blink.cmp

return {
  'saghen/blink.cmp',
  lazy = false, -- lazy loading handled internally
  version = 'v0.*', -- use a release tag to download pre-built binaries
  opts = {
    highlight = { use_nvim_cmp_as_default = true },
    nerd_font_variant = 'normal',

    -- accept = { auto_brackets = { enabled = true } },
    -- trigger = { signature_help = { enabled = true } },

    keymap = {
      show = '<C-Space>',
      accept = '<CR>',
      scroll_documentation_down = {},
      scroll_documentation_up = {},
      snippet_forward = {},
      snippet_backward = {},
    },

    windows = {
      autocomplete = {
        min_width = 20,
        max_width = 40,
        max_height = 15,
        border = 'rounded',
        draw = 'reversed',
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
        auto_show = true,
        auto_show_delay_ms = 500,
        update_delay_ms = 100,
      },
    },
    kind_icons = {
      Text = '',
      Method = '󰆧',
      Function = '󰊕',
      Constructor = '',
      Field = '󰇽',
      Variable = '󰂡',
      Class = '󰠱',
      Interface = '',
      Module = '',
      Property = '󰜢',
      Unit = '',
      Value = '󰎠',
      Enum = '',
      Keyword = '󰌋',
      Snippet = '󰅱',
      Color = '󰏘',
      File = '󰈙',
      Reference = '',
      Folder = '󰉋',
      EnumMember = '',
      Constant = '󰏿',
      Struct = '',
      Event = '',
      Operator = '󰆕',
      TypeParameter = '󰅲',
    },
  },
}
