return {
  "nvim-tree/nvim-web-devicons",
  "nvim-lua/plenary.nvim",
  "nvim-lua/popup.nvim",
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_cursor({}),

            -- pseudo code / specification for writing custom displays, like the one
            -- for "codeactions"
            -- specific_opts = {
            --   [kind] = {
            --     make_indexed = function(items) -> indexed_items, width,
            --     make_displayer = function(widths) -> displayer
            --     make_display = function(displayer) -> function(e)
            --     make_ordinal = function(e) -> string
            --   },
            --   -- for example to disable the custom builtin "codeactions" display
            --      do the following
            --   codeactions = false,
            -- }
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
  { "lvimuser/lsp-inlayhints.nvim", config = true },

  { "tami5/lspsaga.nvim", enabled = false, config = true },

  -- icons on completion
  "onsails/lspkind-nvim", -- lsp function signature help on wildmenu
  {
    "ray-x/lsp_signature.nvim",
    config = function()
      local cfg = {
        hint_enable = false,
        bind = true,
        transparency = 30,
        handler_opts = { border = "rounded" },
      }
      require("lsp_signature").setup(cfg)
    end,
  }, -- floating status text in bottom right
  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({ text = { spinner = "dots" } })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
  }, -- ui elements
  "MunifTanjim/nui.nvim", -- tailwind token colorizer
  {
    "mrshmllow/document-color.nvim",
    enabled = false,
    config = function()
      local docColors = require("document-color")
      docColors.setup({ mode = "background" })
      docColors.buf_attach()
    end,
  }, -- terminal image viewer
  {
    "edluffy/hologram.nvim",
    enabled = false,
    config = function()
      require("hologram").setup({ auto_display = true })
    end,
  }, -- autocompletion
  {
    "hrsh7th/nvim-cmp",
    config = true,
    wants = { "LuaSnip" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip",
    },
  }, -- cmp based copilot
  {
    "zbirenbaum/copilot.lua",
    -- event = { "VimEnter" },
    event = { "BufRead" },
    dependencies = { "zbirenbaum/copilot-cmp" },
    config = function()
      vim.defer_fn(function()
        require("copilot").setup({
          cmp = {
            enabled = true,
            method = "getCompletionsCycling",
            ft_disable = {
              "markdown",
              "neo-tree",
              "terminal",
              "dashboard",
              "telescope.nvim",
              "terraform",
              "lsp-installer",
              "packer",
              "neo-tree-popup",
              "quickfix",
              "notify",
            },
          },
        })
      end, 100)
    end,
  }, -- first-party github copilot plugin
  { "github/copilot.vim", event = "InsertEnter", enabled = false },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      vim.cmd([[highlight IndentBlanklineIndent1 guifg=#E0DEF4 gui=nocombine]])
      vim.cmd([[highlight IndentBlanklineIndent2 guifg=#908CAA gui=nocombine]])
      vim.cmd([[highlight IndentBlanklineIndent3 guifg=#524F67 gui=nocombine]])
      vim.cmd([[highlight IndentBlanklineIndent4 guifg=#403d42 gui=nocombine]])
      vim.cmd([[highlight IndentBlanklineIndent5 guifg=#25233A gui=nocombine]])
      vim.cmd([[highlight IndentBlanklineIndent6 guifg=#21202E gui=nocombine]])

      vim.opt.list = true
      vim.opt.listchars:append("space:⋅")

      require("indent_blankline").setup({
        filetype_exclude = {
          "alpha",
          "neo-tree",
          "lsp-installer",
          "lazy",
          "packer",
          "dashboard",
        },
        space_char_blankline = " ",
        show_current_context = true,
        show_current_context_start = false,
        use_treesitter = true,
        char_highlight_list = {
          "IndentBlanklineIndent1",
          "IndentBlanklineIndent2",
          "IndentBlanklineIndent3",
          "IndentBlanklineIndent4",
          "IndentBlanklineIndent5",
          "IndentBlanklineIndent6",
        },
      })
    end,
  },
  {
    "RRethy/nvim-base16",
  },
  -- other themes
  -- "folke/tokyonight.nvim",
  -- "rmehri01/onenord.nvim",
  -- "wadackel/vim-dogrun",
  -- "challenger-deep-theme/vim",
  -- "EdenEast/nightfox.nvim",
  -- {
  --     "catppuccin/nvim",
  --     name = "catppuccin",
  --     config = function()
  --       require("catppuccin").setup(
  --         {
  --           transparent_background = true,
  --           term_colors = true,
  --           integration = {
  --             nvimtree = {
  --               enabled = true,
  --               transparent_panel = true
  --             },
  --             lsp_trouble = true
  --           }
  --         }
  --       )
  --     end
  --   },
  {
    "norcalli/nvim-colorizer.lua", -- colorize hex codes / color names
    config = function()
      require("colorizer").setup({
        "*",
        css = { rgb_fn = true }, -- disabled in favor of document-color
        html = { names = false },
        "!dart",
      })
    end,
  },
  {
    "glepnir/dashboard-nvim", -- initial launch dashboard
    event = "VimEnter",
    config = function()
      require("dashboard").setup({
        theme = "hyper",
        config = {
          week_header = { enable = true },
          shortcut = {
            {
              desc = " Update",
              group = "@property",
              action = "Lazy update",
              key = "u",
            },
            {
              icon = " ",
              icon_hl = "@variable",
              desc = "Files",
              group = "Label",
              action = "Telescope find_files",
              key = "f",
            },
            {
              desc = " Apps",
              group = "DiagnosticHint",
              action = "Telescope app",
              key = "a",
            },
            {
              desc = " dotfiles",
              group = "Number",
              action = "Telescope dotfiles",
              key = "d",
            },
          },
        },
      })
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  }, -- notifications
  {
    "rcarriga/nvim-notify",
    name = "notify",
    lazy = false,
    config = function()
      local notify = require("notify")
      notify.setup({
        render = "minimal",
        stages = "fade_in_slide_out",
        icons = {
          ERROR = "",
          WARN = "",
          INFO = "",
          DEBUG = "",
          TRACE = "✎",
        },
      })
      vim.notify = notify
    end,
  },
  {
    "folke/which-key.nvim",
    enabled = false,
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  }, -- tpope plugins
  { "tpope/vim-surround" }, -- Change surrounding arks
  { "tpope/vim-repeat" }, -- extends . repeat
}
