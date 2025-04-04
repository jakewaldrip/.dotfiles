-- Blink completion (nvim-cmp replacement)
-- https://github.com/Saghen/blink.cmp

return {
  'saghen/blink.cmp',
  lazy = false, -- lazy loading handled internally
  version = 'v0.*', -- use a release tag to download pre-built binaries
  opts = {

    -- Disable for markdown
    enabled = function()
      return not vim.tbl_contains({ 'markdown', 'copilot-chat' }, vim.bo.filetype) and vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
    end,

    appearance = {
      nerd_font_variant = 'mono',
    },

    completion = {
      accept = { auto_brackets = { enabled = true } },
      menu = {
        border = 'single',
        auto_show = function(ctx)
          return ctx.mode ~= 'cmdline'
        end,
      },
      documentation = { window = { border = 'single' } },
    },

    keymap = {
      preset = 'enter',
    },

    signature = {
      enabled = true,
      window = { border = 'single' },
    },

    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      },
    },
  },
}
