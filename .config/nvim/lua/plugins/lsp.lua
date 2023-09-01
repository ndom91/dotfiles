local function goto_next_error()
  vim.diagnostic.goto_next({ severity = "Error" })
end

local function goto_prev_error()
  vim.diagnostic.goto_prev({ severity = "Error" })
end

vim.g.neoformat_enabled_vue = { "eslint_d", "prettier" }
vim.cmd("let g:neoformat_enabled_vue = ['eslint_d']")

local function format_buffer()
  local current_bufnr = vim.fn.bufnr("%")
  local current_buffer_path = vim.api.nvim_buf_get_name(current_bufnr)
  if string.find(current_buffer_path, "/opt/checkly") then
    vim.cmd("let g:neoformat_enabled_vue = ['eslint_d']")
    vim.g.neoformat_try_node_exe = 1
    vim.cmd(":Neoformat eslint_d")
  else
    vim.cmd(":Neoformat")
  end
end

vim.keymap.set(
  "n",
  "<Leader>lf",
  format_buffer,
  { silent = true, noremap = true }
)

vim.keymap.set(
  "n",
  "<Leader>a",
  vim.lsp.buf.code_action,
  { noremap = true, silent = true }
)

vim.keymap.set("n", "<space>d", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "]e", goto_next_error)
vim.keymap.set("n", "[e", goto_prev_error)
vim.keymap.set("n", "<space>re", vim.lsp.buf.rename)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)

local on_attach = function(client, bufnr)
  local builtin = require("telescope.builtin")
  local opts = { buffer = bufnr }

  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.keymap.set("n", "<Leader>e", builtin.diagnostics, opts)
  vim.keymap.set("n", "gr", builtin.lsp_references, opts)

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help)
  vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

  -- Enable formatting on save sync
  -- if client.supports_method("textDocument/formatting") then
  -- local augroup =
  --   vim.api.nvim_create_augroup("LspFormatting", { clear = true })
  -- vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  -- end
  vim.api.nvim_create_autocmd("BufWritePre", {
    -- group = augroup,
    buffer = bufnr,
    callback = format_buffer(),
    -- format_buffer
    -- vim.cmd(":Neoformat<CR>")
    -- vim.lsp.buf.format({ async = false })
    -- end,
  })
end

local languages = {
  "html",
  "cssls",
  "tsserver",
  "eslint",
  "pyright",
  "gopls",
}

return {
  {
    "folke/neodev.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("neodev").setup({ })
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              globals = { "vim", "describe", "it" },
            },
          },
        },
      })

      -- require("lspconfig").tailwindcss.setup({
      --   on_attach = function()
      --     require("tailwindcss-colors").buf_attach(0)
      --   end,
      -- })

      for _, language in pairs(languages) do
        lspconfig[language].setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end

      vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = false,
        })
    end,
  },
  {
    "sbdchd/neoformat",
  },
  {
    "laytan/tailwind-sorter.nvim",
    enabled = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
    },
    build = "cd formatter && npm i && npm run build",
    config = function()
      require("tailwind-sorter").setup({
        on_save_enabled = true,
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "clangd",
        "html",
        "cssls",
        "tsserver",
        "eslint",
        "tailwindcss",
        "pyright",
        "gopls",
      },
    },
  },
}
