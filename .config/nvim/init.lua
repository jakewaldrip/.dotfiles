require('config.settings')
require('config.keymaps')
require('config.user_commands')
require('config.autocommands')
require('config.diagnostic')

-- LSP Enable
require('config.lsp')
local lsp_dir = vim.fn.stdpath 'config' .. '/lsp'
local lsp_servers = {}

if vim.fn.isdirectory(lsp_dir) == 1 then
  for _, file in ipairs(vim.fn.readdir(lsp_dir)) do
    if file:match '%.lua$' and file ~= 'init.lua' then
      local server_name = file:gsub('%.lua$', '')
      table.insert(lsp_servers, server_name)
    end
  end
end

vim.lsp.enable(lsp_servers)

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
