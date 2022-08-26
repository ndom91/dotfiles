local lspconfig = require "lspconfig"
local utils = require "utils"
local mason = require "mason-lspconfig"

local M = {}

function M.setup(servers, options)

  require("mason").setup {
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  }

  require("mason-tool-installer").setup {
    -- Tools from: https://github.com/williamboman/mason.nvim/tree/main/lua/mason-registry
    ensure_installed = {
      "shellcheck",
      "actionlint",
      "luaformatter",
      "eslint_d",
      -- "prettier_d_slim",
      "prettierd",
      "shfmt",
      "yamllint",
      "tailwindcss-language-server",
      --[[ "vue-language-server", ]]
      "bash-language-server",
      "typescript-language-server",
      "yaml-language-server",
      "lua-language-server"
    },
    auto_update = false,
    run_on_start = true
  }

  require("mason-lspconfig").setup {
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = true
  }

  -- Package installation folder
  local install_root_dir = vim.fn.stdpath "data" .. "/mason"

  require("mason-lspconfig").setup_handlers {
    function(server_name)
      local opts = vim.tbl_deep_extend("force", options,
                                       servers[server_name] or {})
      lspconfig[server_name].setup { opts }
    end,
    ["sumneko_lua"] = function()
      local opts = vim.tbl_deep_extend("force", options,
                                       servers["sumneko_lua"] or {})
      -- lspconfig.sumneko_lua.setup(require("lua-dev").setup { opts })
    end,
    ["tsserver"] = function()
      local opts = vim.tbl_deep_extend("force", options,
                                       servers["tsserver"] or {})
      require("typescript").setup {
        disable_commands = false,
        debug = false,
        server = opts
      }
    end
  }
end

return M
