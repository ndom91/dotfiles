return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    lsp = {
      progress = {
        enabled = false,
      },
      signature = {
        enabled = false,
      },
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = false,
      },
    },
    -- messages = {
    --   enabled = false, -- enables the Noice messages UI
    -- },
    -- cmdline = {
    --   enabled = true, -- enables the Noice cmdline UI
    --   -- view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
    --   title = "",
    -- },
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      --   command_palette = true,        -- position the cmdline and popupmenu together
      --   long_message_to_split = false, -- long messages will be sent to a split
      --   inc_rename = false,            -- enables an input dialog for inc-rename.nvim
      --   lsp_doc_border = false,        -- add a border to hover docs and signature help
    },
    -- commands = {
    --   history = {
    --     view = "popup",
    --   }
    -- },
    views = {
      cmdline_popup = {
        border = {
          style = "none",
          padding = { 1, 2 },
        },
        filter_options = {},
        win_options = {
          winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
        },
      },
      popupmenu = {
        relative = "editor",
        position = {
          row = 8,
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = "none",
          padding = { 1, 2 },
        },
        win_options = {
          -- winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
        },
      },
    },
    routes = {
      {
        filter = {
          event = "notify",
          find = "E486: Pattern not found",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      },
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}
