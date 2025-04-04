return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {}
    end,
  },
  {
    {
      'CopilotC-Nvim/CopilotChat.nvim',
      dependencies = {
        { 'zbirenbaum/copilot.lua' }, -- or zbirenbaum/copilot.lua
        { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
      },
      build = 'make tiktoken', -- Only on MacOS or Linux
      opts = {
        -- See Configuration section for options
        -- TODO: Add prompts here if desired
      },
      vim.keymap.set('n', '<leader>at', ':CopilotChatToggle<CR>', { desc = '[T]oggle Copilot Chat', silent = true }),
      vim.keymap.set('n', '<leader>ap', ':CopilotChatPrompts<CR>', { desc = '[P]rompts', silent = true }),
      vim.keymap.set('n', '<leader>ar', ':CopilotChatReset<CR>', { desc = '[R]eset Chat', silent = true }),
      vim.keymap.set('n', '<leader>as', ':CopilotChatStop<CR>', { desc = '[S]top', silent = true }),
    },
  },
  { 'AndreM222/copilot-lualine' },
}

-- Copilot Chat Contexts
-- > #buffer
-- > #buffer:2
-- > #files:\*.lua
-- > #filenames
-- > #git:staged
-- > #url:https://example.com
-- > #system:`ls -la | grep lua`
