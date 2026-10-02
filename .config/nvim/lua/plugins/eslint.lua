return {
  'esmuellert/nvim-eslint',
  opts = function(plugin)
    return {
      cmd = { 'node', '--max-old-space-size=8196', plugin.dir .. '/vscode-eslint/server/out/eslintServer.js', '--stdio' },
      settings = {
        codeActionOnSave = {
          mode = 'all',
        },
        run = 'onSave',
      },
    }
  end,
}
