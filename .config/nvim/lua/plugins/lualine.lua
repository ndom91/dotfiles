-- local null_ls = require("null-ls")
-- local nls_sources = require("null-ls.sources")
-- local nls_utils = require("null-ls.utils")

local function separator()
  return "%="
end

-- function HasFormatter(filetype)
--   local available = nls_sources.get_available(filetype, null_ls.methods.FORMATTING)
--   return #available > 0
-- end

-- function ListLinter(filetype)
--   local registered_providers = nls_utils.list_registered_providers_names(filetype)
--   return registered_providers[null_ls.methods.DIAGNOSTICS] or {}
-- end

-- function ListHover(filetype)
--   local registered_providers = nls_utils.list_registered_providers_names(filetype)
--   return registered_providers[null_ls.methods.HOVER] or {}
-- end

-- function ListFormatter(filetype)
--   local supported_formatters = nls_sources.get_supported(filetype, "formatting")
--   table.sort(supported_formatters)
--   return supported_formatters
-- end

local function lsp_client(msg)
  msg = msg or ""
  local buf_clients = vim.lsp.get_active_clients()
  if next(buf_clients) == nil then
    if type(msg) == "boolean" or #msg == 0 then
      return ""
    end
    return msg
  end

  local buf_ft = vim.bo.filetype
  local buf_client_names = {}

  -- add client
  -- for _, client in pairs(buf_clients) do
  --   if client.name ~= "null-ls" then
  --     table.insert(buf_client_names, client.name)
  --   end
  -- end

  -- add formatter
  -- local supported_formatters = ListFormatter(buf_ft)
  -- vim.list_extend(buf_client_names, supported_formatters)

  -- add linter
  -- local supported_linters = ListLinter(buf_ft)
  -- vim.list_extend(buf_client_names, supported_linters)

  -- add hover
  -- local supported_hovers = ListHover(buf_ft)
  -- vim.list_extend(buf_client_names, supported_hovers)

  return "[" .. table.concat(buf_client_names, ", ") .. "]"
end

return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("lualine").setup({
      options = {
        -- theme = "auto",
        theme = "catppuccin",
        -- always_divide_middle = true,
        icons_enabled = true,
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          winbar = { "neo-tree", "packer", "help", "toggleterm" },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            "filename",
            file_status = true,     -- Displays file status (readonly status, modified status)
            newfile_status = false, -- Display new file status (new file means no write after created)
            path = 1,               -- 0: Just the filename
            -- 1: Relative path
            -- 2: Absolute path
            -- 3: Absolute path, with tilde as the home directory
            -- 4: Filename and parent dir, with tilde as the home directory

            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
            -- for other components. (terrible name, any suggestions?)
            symbols = {
              modified = "*",        -- Text to show when the file is modified.
              readonly = "RO",       -- Text to show when the file is non-modifiable or readonly.
              unnamed = "[No Name]", -- Text to show for unnamed buffers.
              newfile = "[New]",     -- Text to show for newly created file before first write
            },
          },
          -- "branch",
          { "b:gitsigns_head", icon = "" },
          {
            "diff",
            colored = true,                                           -- Displays a colored diff status if set to true
            symbols = { added = "+", modified = "~", removed = "-" }, -- Changes the symbols used by the diff.
          },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            sections = { "error", "warn", "info", "hint" },
            -- symbols = { error = " ", warn = " ", info = " ", hint = " " },
            symbols = { error = "E", warn = "W", info = "I", hint = "H" },
            colored = true,           -- Displays diagnostics status in color if set to true.
            update_in_insert = false, -- Update diagnostics in insert mode.
            always_visible = false,   -- Show diagnostics even if there are none.
          },
        },
        lualine_c = {
          { separator },
          -- { lsp_client, icon = " ", color = { gui = "bold" } },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            file_status = true, -- displays file status (readonly status, modified status)
            path = 1,           -- 0 = just filename, 1 = relative path, 2 = absolute path
          },
        },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {},
      -- extensions = { "nvim-tree" },
    })
  end,
}
