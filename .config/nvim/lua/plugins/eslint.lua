function get_plugin_root()
  local str = debug.getinfo(1, 'S').source:sub(2)
  return vim.fn.fnamemodify(str, ':p:h:h:h')
end

-- TODO: Find a way to automatically resolve this via lua
-- For Mac
local path = '/Users/jacob.waldrip/.local/share/nvim/lazy/nvim-eslint'

-- For Arch
-- local path = '/home/jacob/.local/share/nvim/lazy/nvim-eslint'

return {
  'esmuellert/nvim-eslint',
  opts = {
    cmd = { 'node', '--max-old-space-size=8196', path .. '/vscode-eslint/server/out/eslintServer.js', '--stdio' },
    settings = {
      codeActionOnSave = {
        mode = 'all',
      },
      run = 'onSave',
    },
  },
}
