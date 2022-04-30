vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local packer = require("packer")

packer.init({
  git = {
    clone_timeout = 300,
    subcommands = { install = "clone --depth %i --progress" }
  },
  profile = { enable = true }
})

packer.startup(function(use)
  -- nerd font icons
  use "kyazdani42/nvim-web-devicons"

  -- telescope
  use "nvim-lua/plenary.nvim"
  use "nvim-lua/popup.nvim"
  use {
    "nvim-telescope/telescope.nvim",
    config = function()
      require "plugin_configs.telescope"
    end
  }
  use { "nvim-telescope/telescope-ui-select.nvim" }

  -- builtin lsp
  use {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugin_configs.lsp-config"
    end
  }

  use "williamboman/nvim-lsp-installer"

  use {
    "folke/trouble.nvim",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("trouble").setup {}
    end
  }
  use {
    'tami5/lspsaga.nvim',
    config = function()
      require "plugin_configs.lsp-saga"
    end
  }

  -- neo-tree
  use "MunifTanjim/nui.nvim"
  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim"
    },
    config = function()
      require "plugin_configs.neo-tree"
    end
  }

  use({
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require("plugin_configs.null-ls")
    end,
    requires = { "nvim-lua/plenary.nvim" }
  })

  use "b0o/schemastore.nvim"
  use "jose-elias-alvarez/nvim-lsp-ts-utils"

  -- auto-completion
  use {
    "hrsh7th/nvim-cmp",
    config = function()
      require "plugin_configs.nvim-cmp"
    end
  }

  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-cmdline"
  use "hrsh7th/cmp-vsnip"
  use "hrsh7th/vim-vsnip"
  use "onsails/lspkind-nvim"

  -- lsp function signature
  use {
    "ray-x/lsp_signature.nvim",
    config = function()
      cfg = {
        hint_enable = false,
        bind = true,
        transparency = 30,
        handler_opts = { border = "rounded" }
      }
      require"lsp_signature".setup(cfg)
    end
  }

  -- treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require "plugin_configs.treesitter"
    end
  }

  -- comments
  use {
    "numToStr/Comment.nvim",
    config = function()
      require "plugin_configs.comment"
    end
  }

  -- todo comments
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end
  }

  -- indent
  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
        space_char_blankline = " ",
        show_current_context = true,
        show_current_context_start = true
      }
    end
  }

  -- comments integration with treesitter
  use { "JoosepAlviste/nvim-ts-context-commentstring", after = "nvim-treesitter" }

  -- lualine
  use {
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require "plugin_configs.lualine"
    end
  }

  -- bufferline (tabs)
  use {
    "akinsho/bufferline.nvim",
    tag = "*",
    config = function()
      require "plugin_configs.bufferline"
    end
  }

  -- theme
  -- use "folke/tokyonight.nvim"
  -- use "rmehri01/onenord.nvim"
  -- use "wadackel/vim-dogrun"
  -- use "challenger-deep-theme/vim"
  -- use "EdenEast/nightfox.nvim"
  -- use(
  --   {
  --     "catppuccin/nvim",
  --     as = "catppuccin",
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
  --   }
  -- )

  use({
    "rose-pine/neovim",
    config = function()
      require "plugin_configs.rose-pine"
    end
  })

  -- git
  use {
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = {
            hl = "GitSignsAdd",
            text = "│",
            numhl = "GitSignsAddNr",
            linehl = "GitSignsAddLn"
          },
          change = {
            hl = "GitSignsChange",
            text = "│",
            numhl = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn"
          },
          delete = {
            hl = "GitSignsDelete",
            text = "_",
            numhl = "GitSignsDeleteNr",
            linehl = "GitSignsDeleteLn"
          },
          topdelete = {
            hl = "GitSignsDelete",
            text = "‾",
            numhl = "GitSignsDeleteNr",
            linehl = "GitSignsDeleteLn"
          },
          changedelete = {
            hl = "GitSignsChange",
            text = "~",
            numhl = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn"
          }
        }
      })
    end
  }

  -- hex colorizer
  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        "*",
        css = { rgb_fn = true },
        html = { names = false }
      })
    end
  }

  -- toggle-term
  use {
    "akinsho/toggleterm.nvim",
    config = function()
      require "plugin_configs.toggleterm"
    end
  }

  use {
    "glepnir/dashboard-nvim",
    config = function()
      require "plugin_configs.dashboard"
    end
  }

  use {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end
  }

  -- vimscript plugins
  use "tpope/vim-surround"

end)
