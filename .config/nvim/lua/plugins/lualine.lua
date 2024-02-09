return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "AndreM222/copilot-lualine",
    {
      "b0o/incline.nvim",
      opts = {
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          local buffer = {
            ft_icon
                and { " ", ft_icon, "  ", guibg = ft_color, guifg = require("incline.helpers").contrast_color(ft_color) }
              or "",
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = "#44406e",
          }
          return buffer
        end,
      },
      event = "VeryLazy",
    },
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
        component_separators = "",
        section_separators = "",
        disabled_filetypes = {
          winbar = { "neo-tree", "packer", "help", "toggleterm" },
        },
      },
      sections = {
        lualine_a = {
          "mode",
        },
        lualine_b = {
          {
            "filename",
            file_status = true, -- Displays file status (readonly status, modified status)
            newfile_status = false, -- Display new file status (new file means no write after created)
            path = 1, -- 0: Just the filename
            -- 1: Relative path
            -- 2: Absolute path
            -- 3: Absolute path, with tilde as the home directory
            -- 4: Filename and parent dir, with tilde as the home directory
            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
            symbols = {
              modified = "●", -- Text to show when the file is modified.
              readonly = "RO", -- Text to show when the file is non-modifiable or readonly.
              unnamed = "[No Name]", -- Text to show for unnamed buffers.
              newfile = "[New]", -- Text to show for newly created file before first write
            },
          },
        },
        lualine_c = {
          -- { separator },
          { "b:gitsigns_head", icon = "" },
          {
            "diff",
            colored = true, -- Displays a colored diff status if set to true
            symbols = { added = "+", modified = "~", removed = "-" }, -- Changes the symbols used by the diff.
          },
        },
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            sections = { "error", "warn", "info", "hint" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            -- symbols = { error = "E", warn = "W", info = "I", hint = "H" },
            colored = true, -- Displays diagnostics status in color if set to true.
            update_in_insert = false, -- Update diagnostics in insert mode.
            always_visible = false, -- Show diagnostics even if there are none.
          },
          {
            "copilot",
            show_colors = true,
            padding = 2,
            symbols = {
              spinners = require("copilot-lualine.spinners").dots,
            },
          },
          { -- lsp
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return " " .. #clients end
              return "  " .. table.concat(vim.tbl_map(function(client) return client.name end, clients), ", ")
            end,
          },
          -- "fileformat",
        },
        lualine_y = {
          -- "location"
          "progress",
        },
        lualine_z = {
          -- "fileformat",
          {
            "filetype",
            colored = false,
            icon_only = false,
            icons_enabled = true,
            icon = { align = "right" },
            padding = 2,
          },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
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
        "lazy",
      },
    })
  end,
}
