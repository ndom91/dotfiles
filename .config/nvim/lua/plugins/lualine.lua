-- local function lsp_client(msg)
--   msg = msg or ""
--   local buf_clients = vim.lsp.buf_get_clients()
--   if next(buf_clients) == nil then
--     if type(msg) == "boolean" or #msg == 0 then return "" end
--     return msg
--   end
--
--   local buf_ft = vim.bo.filetype
--   local buf_client_names = {}
--
--   -- add client
--   for _, client in pairs(buf_clients) do
--     if client.name ~= "null-ls" then
--       table.insert(buf_client_names, client.name)
--     end
--   end
--
--   -- add formatter
--   -- local formatters = require "plugins.lsp.null-ls.formatters"
--   -- local supported_formatters = formatters.list_registered(buf_ft)
--   -- vim.list_extend(buf_client_names, supported_formatters)
--
--   -- add linter
--   -- local linters = require "plugins.lsp.null-ls.linters"
--   -- local supported_linters = linters.list_registered(buf_ft)
--   -- vim.list_extend(buf_client_names, supported_linters)
--
--   -- add hover
--   -- local hovers = require "plugins.lsp.null-ls.hovers"
--   -- local supported_hovers = hovers.list_registered(buf_ft)
--   -- vim.list_extend(buf_client_names, supported_hovers)
--
--   return "[" .. table.concat(buf_client_names, ", ") .. "]"
-- end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        -- theme = "tokyonight",
        theme = "rose-pine",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {},
        always_divide_middle = true
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "filename",
          "branch",
          "diff",
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            colored = false
          }
        },
        -- { "diagnostics", sources = { "nvim_lsp" } } },
        -- lualine_c = { "filename" },
        -- lualine_c = {
        --   { lsp_client, icon = " ", color = { fg = "#a9a1e1", gui = "bold" } }
        -- },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      -- extensions = {"nvim-tree", "quickfix"}
      extensions = {}
    }
  end
}
