-- Telescope, pickers for navigating files and directories
-- https://github.com/nvim-telescope/telescope.nvim

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',

      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    require('telescope').setup {
      defaults = {
        mappings = {
          n = {
            ['d'] = require('telescope.actions').delete_buffer,
            ['q'] = require('telescope.actions').close,
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local no_preview = function()
      return require('telescope.themes').get_dropdown {
        borderchars = {
          { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
          results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
          preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        },
        width = 0.8,
        previewer = false,
        prompt_title = false,
      }
    end

    local pickers = require 'telescope.pickers'
    local finders = require 'telescope.finders'
    local make_entry = require 'telescope.make_entry'
    local conf = require('telescope.config').values

    local live_multigrep = function(opts)
      opts = opts or {}
      opts.cwd = opts.cwd or vim.uv.cwd()

      local finder = finders.new_async_job {
        command_generator = function(prompt)
          if not prompt or prompt == '' then
            return nil
          end

          local pieces = vim.split(prompt, '  ')
          local args = { 'rg' }
          if pieces[1] then
            table.insert(args, '-e')
            table.insert(args, pieces[1])
          end

          if pieces[2] then
            table.insert(args, '-g')
            table.insert(args, pieces[2])
          end

          ---@diagnostic disable-next-line: deprecated
          return vim.tbl_flatten {
            args,
            { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
          }
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
      }

      pickers
        .new(opts, {
          debounce = 100,
          prompt_title = 'Multi Grep',
          finder = finder,
          previewer = conf.grep_previewer(opts),
          sorter = require('telescope.sorters').empty(),
        })
        :find()
    end

    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>sc', builtin.git_status, { desc = '[S]earch [C]hanges' })
    vim.keymap.set('n', '<leader>sg', live_multigrep)

    vim.keymap.set('n', '<leader>s.', function()
      builtin.oldfiles { layout_strategy = 'vertical', layout_config = { width = 0.5, height = 0.9 } }
    end, { desc = '[S]earch Recent Files ("." for repeat)' })

    vim.keymap.set('n', '<leader><leader>', function()
      builtin.buffers(no_preview())
    end, { desc = '[ ] Find Existing Buffers' })

    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sif', function()
      builtin.find_files { hidden = true }
    end, { desc = '[S]earch [I]nvisible [F]iles' })

    vim.keymap.set('n', '<leader>sig', function()
      builtin.live_grep { hidden = true }
    end, { desc = '[S]earch [I]nvisible [G]rep' })
  end,
}
