-- Mini.nvim
-- Collection of various small independent plugins/modules

return {
  'echasnovski/mini.nvim',
  config = function()
    -- Prettify Notifications
    local mini_notify = require 'mini.notify'
    mini_notify.setup()
    vim.notify = mini_notify.make_notify {
      ERROR = { duration = 5000 },
      WARN = { duration = 4000 },
      INFO = { duration = 3000 },
    }

    -- Autopairs
    require('mini.pairs').setup()

    -- Move selection
    require('mini.move').setup()

    -- Split/Join operators
    require('mini.splitjoin').setup()

    -- Animate Indent Scope
    require('mini.indentscope').setup()
  end,
}
