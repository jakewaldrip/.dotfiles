-- LSP Configuration and keybindings

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', opts = {} }, -- NOTE: Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Blink
    { 'saghen/blink.cmp', opts = {} },
  },
  config = function(_, opts)
    -- Map telescope bindings when LSP attaches
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- Find references for the word under your cursor.
        map('grf', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Jump to the type of the word under your cursor.
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        -- Fuzzy find all the symbols in your current document.
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

        -- Fuzzy find all the symbols in your current workspace.
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- Jump to the Declaration of the word under your cursor (ie, C header file)
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Highlight references of word under cursor on cursor hold
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- Add toggle for inlay hints if lsp supports
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })

          -- Highlight word under cursor
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          -- Clear highlighted word under cursor
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          -- Clear highlights on lsp detatch
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(other_event)
              vim.lsp.buf.clear_references()

              vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = other_event.buf }
            end,
          })
        end

        -- Change diagnostic symbols in the sign column (gutter)
        if vim.g.have_nerd_font then
          local signs = { Error = '', Warn = '', Hint = '', Info = '' }
          for type, icon in pairs(signs) do
            local hl = 'DiagnosticSign' .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
          end
        end
      end,
    })

    -- Enable the following language servers
    local servers = {
      pyright = {},
      rust_analyzer = {},
      -- eslint_d = {},
      ts_ls = {
        init_options = {
          hostInfo = 'neovim',
          maxTsServerMemory = 8192,
          preferences = {
            includePackageJsonAutoImports = 'off',
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
            importModuleSpecifierPreference = 'non-relative',
          },
        },
        settings = {
          inlay_hints = {
            enabled = true,
          },
        },
      },

      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
    }

    -- Setup language server via mason (LSP manager)
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format Lua code
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities)
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
