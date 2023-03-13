local null_ls = require "null-ls"
local nls_sources = require "null-ls.sources"
local nls_utils = require "null-ls.utils"

local function separator()
  return "%="
end

function HasFormatter (filetype)
  local available = nls_sources.get_available(filetype, null_ls.methods.FORMATTING)
  return #available > 0
end

function ListLinter(filetype)
  local registered_providers = nls_utils.list_registered_providers_names(filetype)
  return registered_providers[null_ls.methods.DIAGNOSTICS] or {}
end

function ListHover(filetype)
  local registered_providers = nls_utils.list_registered_providers_names(filetype)
  return registered_providers[null_ls.methods.HOVER] or {}
end

function ListFormatter(filetype)
  local supported_formatters = nls_sources.get_supported(filetype, "formatting")
  table.sort(supported_formatters)
  return supported_formatters
end

local function lsp_client(msg)
  msg = msg or ""
  local buf_clients = vim.lsp.get_active_clients()
  if next(buf_clients) == nil then
    if type(msg) == "boolean" or #msg == 0 then return "" end
    return msg
  end

  local buf_ft = vim.bo.filetype
  local buf_client_names = {}

  -- add client
  for _, client in pairs(buf_clients) do
    if client.name ~= "null-ls" then
      table.insert(buf_client_names, client.name)
    end
  end

  -- add formatter
  local supported_formatters = ListFormatter(buf_ft)
  vim.list_extend(buf_client_names, supported_formatters)

  -- add linter
  local supported_linters = ListLinter(buf_ft)
  vim.list_extend(buf_client_names, supported_linters)

  -- add hover
  local supported_hovers = ListHover(buf_ft)
  vim.list_extend(buf_client_names, supported_hovers)

  return "[" .. table.concat(buf_client_names, ", ") .. "]"
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        -- theme = "rose-pine",
        theme = "auto",
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
          },
        },
        lualine_c = {
          { separator },
          { lsp_client, icon = " ", color = { gui = "bold" } }
        },
        -- { "diagnostics", sources = { "nvim_lsp" } } },
        -- lualine_c = { "filename" },
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
