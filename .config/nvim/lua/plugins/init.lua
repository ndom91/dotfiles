return {
  "nvim-tree/nvim-web-devicons",
  "nvim-lua/plenary.nvim",
  "nvim-lua/popup.nvim",
  {
    "tami5/lspsaga.nvim",
    enabled = true,
    event = "LspAttach",
    config = function() require("lspsaga").setup {} end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- icons on completion
  "onsails/lspkind-nvim",

  {
    "lvimuser/lsp-inlayhints.nvim",
    enabled = false,
    config = true,
  },
  -- lsp function signature help on wildmenu
  {
    "ray-x/lsp_signature.nvim",
    enabled = true,
    opts = {
      hint_enable = true,
      hint_inline = function() return false end,
      floating_window = false,
      bind = true,
    },
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      integration = {
        ["nvim-tree"] = {
          enable = true,
        },
      },
      progress = {
        display = {
          progress_icon = {
            pattern = "dots",
            period = 1,
          },
        },
      },
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },
  {
    "folke/trouble.nvim",
    enabled = true,
    config = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>tr", function() require("trouble").toggle() end, { desc = "Toggle Trouble" } },
      {
        "<leader>trw",
        function() require("trouble").toggle "workspace_diagnostics" end,
        { desc = "Toggle Trouble Type Definitions" },
      },
      {
        "<leader>trd",
        function() require("trouble").toggle "lsp_type_definitions" end,
        { desc = "Toggle Trouble Type Definitions" },
      },
      {
        "<leader>trr",
        function() require("trouble").toggle "lsp_references" end,
        { desc = "Toggle Trouble Type Definitions" },
      },
    },
  },
  -- tailwind token colorizer
  {
    "mrshmllow/document-color.nvim",
    enabled = false,
    keys = {
      { "<leader>lC", "require('document-color').buf_toggle()" },
    },
    config = function()
      local docColors = require "document-color"
      docColors.setup { mode = "background" }
      docColors.buf_attach()
    end,
  },
  -- cmp based copilot
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    event = "VeryLazy",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = false,
        javascript = true,
        typescript = true,
        typescriptreact = true,
        javascriptreact = true,
        lua = true,
        bash = true,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
            -- disable for .env files
            return false
          end
          return true
        end,
        ["."] = false,
      },
    },
  },
  -- first-party github copilot plugin
  {
    "github/copilot.vim",
    event = "InsertEnter",
    enabled = false,
  },
  {
    "RRethy/nvim-base16",
    enabled = false,
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      filetypes = { "*" },
      user_default_options = {
        names = false,
        RRGGBBAA = true,
        css = true,
        tailwind = true,
        mode = "background",
      },
    },
  },
  {
    "glepnir/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      theme = "hyper",
      config = {
        week_header = { enable = true },
        packages = { enable = true }, -- show how many plugins neovim loaded
        project = { enable = false, limit = 8, icon = "your icon", label = "", action = "Telescope find_files cwd=" },
        mru = { limit = 10, label = "Most Recent", cwd_only = false },
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
            action = "Telescope find_files cwd=",
            key = "f",
          },
          {
            desc = " dotfiles",
            group = "Number",
            action = "Telescope dotfiles",
            key = "d",
          },
        },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      local notify = require "notify"
      notify.setup {
        render = "wrapped-compact",
        background_colour = "#191724",
        -- icons = {
        --   ERROR = '',
        --   WARN = '',
        --   INFO = '',
        --   DEBUG = '',
        --   TRACE = '✎',
        -- },
      }
      vim.notify = notify
    end,
  },
  {
    "folke/which-key.nvim",
    enabled = false,
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    enabled = false,
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      {
        "S",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter",
      },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search",
      },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {},
  },
  {
    "kdheepak/lazygit.nvim",
    keys = {
      { "<leader>lg", "<cmd>LazyGit<CR>", { noremap = true, silent = true } },
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "tpope/vim-surround",
    enabled = false,
  },
  { "tpope/vim-repeat" },
}
