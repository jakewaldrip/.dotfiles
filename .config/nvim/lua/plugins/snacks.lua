return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    -- Core
    picker = {
      sources = {
        buffers = {
          layout = {
            preview = false,
            layout = {
              backdrop = false,
              width = 0.4,
              min_width = 20,
              height = 0.4,
              border = 'rounded',
              box = 'vertical',
              { win = 'input', height = 1, border = 'rounded', title = '{title} {live} {flags}', title_pos = 'center' },
              { win = 'list', border = 'hpad' },
            },
          },
        },
        recent = {
          layout = {
            layout = {
              backdrop = false,
              width = 0.5,
              min_width = 80,
              height = 0.8,
              border = 'rounded',
              box = 'vertical',
              { win = 'preview', title = '{preview}', height = 0.6, border = 'rounded' },
              {
                box = 'vertical',
                border = 'rounded',
                title = '{title} {live} {flags}',
                title_pos = 'center',
                { win = 'list', border = 'none' },
                { win = 'input', height = 1, border = 'top' },
              },
            },
          },
        },
      },
    },

    explorer = { enabled = true },
    git = { enabled = true },
    rename = { enabled = true },

    -- Optimization
    bigfile = { enabled = true },
    quickfile = { enabled = true },

    -- View
    statuscolumn = { enabled = true },
    notifier = { enabled = true },
    input = { enabled = true },
  },
  keys = {
    -- Pickers & Explorer
    {
      '<leader>sf',
      function()
        Snacks.picker.smart()
      end,
      desc = 'Smart Find [F]iles',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Buffers',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = '[G]rep',
    },
    {
      '<leader>s;',
      function()
        Snacks.picker.command_history()
      end,
      desc = 'Command History',
    },
    {
      '<leader>sn',
      function()
        Snacks.picker.notifications()
      end,
      desc = '[N]otification History',
    },
    {
      '\\',
      function()
        Snacks.explorer()
      end,
      desc = 'File Explorer',
    },
    {
      '<leader>sc',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = 'Find [C]onfig File',
    },
    {
      '<leader>sa',
      function()
        Snacks.picker.files()
      end,
      desc = '[A]ll Find Files',
    },
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = 'Recent',
    },
    {
      '<leader>so',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = 'Grep [O]pen Buffers',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = 'Visual selection or word',
      mode = { 'n', 'x' },
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.search_history()
      end,
      desc = 'Search History',
    },
    {
      '<leader>se',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = '[E]rrors',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = '[K]eymaps',
    },
    {
      '<leader>sq',
      function()
        Snacks.picker.qflist()
      end,
      desc = '[Q]uickfix List',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = '[R]esume',
    },
    {
      '<leader>su',
      function()
        Snacks.picker.undo()
      end,
      desc = '[U]ndo History',
    },
    {
      '<leader>uC',
      function()
        Snacks.picker.colorschemes()
      end,
      desc = '[C]olorschemes',
    },

    -- git
    {
      '<leader>gb',
      function()
        Snacks.git.blame_line()
      end,
      desc = 'Git [B]lame',
    },
    {
      '<leader>ga',
      function()
        Snacks.picker.git_branches()
      end,
      desc = 'Git Br[a]nches',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log()
      end,
      desc = 'Git [L]og',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status()
      end,
      desc = 'Git [S]tatus',
    },
    {
      '<leader>gd',
      function()
        Snacks.picker.git_diff()
      end,
      desc = 'Git [D]iff (Hunks)',
    },

    -- LSP
    {
      'gd',
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = '[G]oto [D]efinition',
    },
    {
      'gD',
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = '[G]oto [D]eclaration',
    },
    {
      'grf',
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = '[R]eferences',
    },
    {
      'gI',
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = '[G]oto [I]mplementation',
    },
    {
      'gy',
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = 'Goto T[y]pe Definition',
    },
    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = '[B]uffer [D]elete',
    },
    {
      '<leader>rf',
      function()
        Snacks.rename.rename_file()
      end,
      desc = '[R]ename [F]ile',
    },
  },

  -- Setup Autocommands
  init = function()
    vim.api.nvim_create_autocmd('LspProgress', {
      callback = function(ev)
        local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
        vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
          id = 'lsp_progress',
          title = 'LSP Progress',
          opts = function(notif)
            notif.icon = ev.data.params.value.kind == 'end' and ' ' or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })
  end,
}
