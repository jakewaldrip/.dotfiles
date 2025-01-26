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
    local notify = require 'mini.notify'
    vim.notify = notify.make_notify {
      ERROR = { duration = 5000 },
      WARN = { duration = 5000 },
      INFO = { duration = 5000 },
    }
  end,
}
