-- Mini.nvim
-- Collection of various small independent plugins/modules

return {
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    require('mini.surround').setup()

    -- Prettify Notifications
    require('mini.notify').setup()
  end,
}
