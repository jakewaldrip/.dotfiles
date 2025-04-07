function get_plugin_root()
  local str = debug.getinfo(1, 'S').source:sub(2)
  return vim.fn.fnamemodify(str, ':p:h:h:h')
end

local path = '/Users/jacob.waldrip/.local/share/nvim/lazy/nvim-eslint'

return {
  'esmuellert/nvim-eslint',
  opts = {
    cmd = { 'node', path .. '/vscode-eslint/server/out/eslintServer.js', '--stdio', '--max-old-space-size=8182' },
    settings = {
      run = 'onSave',
    },
  },
}
