local function goto_next_error()
  vim.diagnostic.goto_next({ severity = "Error" })
end

local function goto_prev_error()
  vim.diagnostic.goto_prev({ severity = "Error" })
end

-- local function format_buffer()
--   vim.lsp.buf.format({
--     async = false,
--     filter = function(client)
--       return client.name ~= "null-ls"
--       -- local current_bufnr = vim.fn.bufnr("%")
--       -- local current_buffer_path = vim.api.nvim_buf_get_name(current_bufnr)
--       -- if string.find(current_buffer_path, "/opt/checkly") then
--       -- 	print("CHECKLY PATH")
--       --        return client.name ~= "tsserver" and client.name ~= "pyright" and client.name ~= "eslint"
--       -- else
--       -- 	print("LSP FORMAT")
--       -- 	return client.name ~= "tsserver" and client.name ~= "pyright" and client.name ~= "eslint"
--       -- end
--     end,
--   })
-- end

vim.keymap.set(
  "n",
  "<Leader>lf",
  ":Neoformat<CR>",
  { silent = true, noremap = true }
)

vim.g.neoformat_try_node_exe = 1

vim.keymap.set(
  "n",
  "<Leader>e",
  vim.diagnostic.open_float,
  { noremap = true, silent = true }
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

-- vim.api.nvim_create_autocmd("LspAttach", {
--   group = vim.api.nvim_create_augroup("UserLspConfig", {}),
--   callback = function(ev)
--     vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
--
--     local opts = { buffer = ev.buf }
--     vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
--     vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
--     vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
--     vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
--     vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
--     vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
--     -- vim.keymap.set("n", "<leader>lf", format_buffer, opts)
--   end,
-- })

local on_attach = function(client, bufnr)
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  -- Enable formatting on save sync
  if client.supports_method("textDocument/formatting") then
    local augroup =
      vim.api.nvim_create_augroup("LspFormatting", { clear = true })
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.cmd(":Neoformat<CR>")
        -- vim.lsp.buf.format({ async = false })
      end,
    })
  end
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
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("lspconfig").lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
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
        require("lspconfig")[language].setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end

      vim.keymap.set(
        "n",
        "<Leader>fa",
        ":EslintFixAll<CR>",
        { noremap = true, silent = true }
      )

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
    enabled = "false",
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
    "folke/neodev.nvim",
    config = true,
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
