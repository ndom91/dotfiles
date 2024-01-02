local function separator()
  return "%="
end

return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    'AndreM222/copilot-lualine'
  },
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin",
        globalstatus = true,
        -- Old
        -- component_separators = { left = "", right = "" },
        -- section_separators = { left = "", right = "" },
        -- Current
        -- component_separators = { left = "╱", right = "╱" },
        -- section_separators = { left = "", right = "" },
        --
        component_separators = '',
        section_separators = '',
        disabled_filetypes = {
          winbar = { "neo-tree", "packer", "help", "toggleterm" },
        },
      },
      sections = {
        lualine_a = {
          "mode"
        },
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
        },
        lualine_c = {
          -- { separator },
          { "b:gitsigns_head", icon = "" },
        },
        lualine_x = {
          {
            "diff",
            colored = true,                                           -- Displays a colored diff status if set to true
            symbols = { added = "+", modified = "~", removed = "-" }, -- Changes the symbols used by the diff.
          },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            sections = { "error", "warn", "info", "hint" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            -- symbols = { error = "E", warn = "W", info = "I", hint = "H" },
            colored = true,           -- Displays diagnostics status in color if set to true.
            update_in_insert = false, -- Update diagnostics in insert mode.
            always_visible = false,   -- Show diagnostics even if there are none.
          },
          {
            "copilot",
            show_colors = true,
            padding = 2,
            symbols = {
              spinners = require("copilot-lualine.spinners").dots,
            }
          },
          -- "encoding",
          -- "fileformat",
        },
        lualine_y = {
          -- "location"
          "progress"
        },
        lualine_z = {
          {
            "filetype",
            colored = true,
            icon_only = false,
            icons_enabled = false,
            icon = { align = "right" }
          }
        },
      },
      inactive_sections = {
        lualine_a = {
        },
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            file_status = true, -- displays file status (readonly status, modified status)
            path = 1,           -- 0 = just filename, 1 = relative path, 2 = absolute path
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {
        "neo-tree",
        "mason",
        "man",
        "nvim-dap-ui",
        "toggleterm",
        "trouble",
        "lazy"
      },
    })
  end,
}
