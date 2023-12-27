local function goto_next_error() vim.diagnostic.goto_next { severity = 'Error' } end
local function goto_prev_error() vim.diagnostic.goto_prev { severity = 'Error' } end

vim.keymap.set('n', '<Leader>lf', function()
  vim.lsp.buf.format {
    async = false,
    filter = function(client) return client.name ~= "volar" or client.name ~= "svelteserver" end
  }
end, { silent = true, noremap = true, desc = "Format" })

-- vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action, { noremap = true, silent = true })
vim.keymap.set('n', '<space>d', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', ']e', goto_next_error)
vim.keymap.set('n', '[e', goto_prev_error)
vim.keymap.set('n', '<space>re', vim.lsp.buf.rename)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)

local on_attach = function(client, bufnr)
  local builtin = require 'telescope.builtin'
  local opts = { buffer = bufnr }

  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.keymap.set('n', '<Leader>e', builtin.diagnostics, opts)
  vim.keymap.set('n', 'gr', builtin.lsp_references, opts)

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help)
  vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

  -- Highlight symbol references on hover
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup('LspDocumentHighlight', { clear = false })
    vim.api.nvim_clear_autocmds {
      buffer = bufnr,
      group = 'LspDocumentHighlight',
    }
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = 'LspDocumentHighlight',
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = 'LspDocumentHighlight',
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  -- Autoformatting
  if client.supports_method 'textDocument/formatting' then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format {
          async = false,
          filter = function(cl) return cl.name ~= "volar" or cl.name ~= "svelteserver" end
        }
      end
    })
  end
end

local languages = {
  'html',
  'cssls',
  'tsserver', -- handled by typescript-tools
  'eslint',
  'pyright',
  'gopls',
  'tailwindcss',
  'volar',
  'bashls',
  'dockerls',
  'lua_ls',
  'svelte'
}

return {
  {
    'folke/neodev.nvim',
    opts = {}
  },
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        'js-debug-adapter',
        'lua-language-server',
        'typescript-language-server',
        'bash-language-server',
        'css-lsp',
        'eslint-lsp',
        'eslintd',
        'html-lsp',
        'svelte-language-server',
        'tailwindcss-language-server',
        'vue-language-server',
        'shellcheck',
        'shfmt',
      })
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      automatic_installation = true,
      ensure_installed = languages,
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      require('neodev').setup {}
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require 'lspconfig'

      for _, language in pairs(languages) do
        lspconfig[language].setup {
          capabilities = capabilities,
          on_attach = on_attach,
        }
      end

      vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
      })
    end,
  },
  {
    'sbdchd/neoformat',
    enabled = false
  },
  {
    'stevearc/conform.nvim',
    enabled = false
  },
  {
    "pmizio/typescript-tools.nvim",
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        tsserver_file_preferences = {
          importModuleSpecifierPreference = "non-relative",
          jsx_close_tag = {
            enable = true,
            filetypes = { "javascriptreact", "typescriptreact" },
          }
        }
      }
    },
  },
  {
    'laytan/tailwind-sorter.nvim',
    enabled = true,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-lua/plenary.nvim',
    },
    build = 'cd formatter && npm i && npm run build',
    config = function()
      require('tailwind-sorter').setup {
        on_save_enabled = true,
        on_save_pattern = { '*.vue', '*.html', '*.js', '*.jsx', '*.ts', '*.tsx', '*.astro', '*.svelte' },
      }
    end,
  },
}
