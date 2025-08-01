-- Mini.nvim
-- Collection of various small independent plugins/modules

return {
  'echasnovski/mini.nvim',
  config = function()
    -- Autopairs
    require('mini.pairs').setup({
      mappings = {
        ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^%a\\].', register = { cr = false } },
        ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^%a\\].', register = { cr = false } },
      },
    })

    -- Move selection
    require('mini.move').setup()

    -- Split/Join operators
    require('mini.splitjoin').setup()

    -- Animate Indent Scope
    require('mini.indentscope').setup()
  end,
}
