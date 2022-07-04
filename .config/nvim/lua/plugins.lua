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
      require "plugins.telescope"
    end
  }
  use { "nvim-telescope/telescope-ui-select.nvim" }

  -- lsp
  use {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.lsp.lsp-config"
    end
  }

  use "williamboman/nvim-lsp-installer"

  use {
    'tami5/lspsaga.nvim',
    config = function()
      require "plugins.lsp.lsp-saga"
    end
  }

  use "onsails/lspkind-nvim" -- icons on completion

  -- lsp function signature help on wildmenu
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

  use({
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require("plugins.lsp.null-ls")
    end,
    requires = { "nvim-lua/plenary.nvim" }
  })

  use({
    "j-hui/fidget.nvim", -- floating status text in bottom right
    config = function()
      require("plugins.fidget-nvim")
    end
  })

  use("rrethy/vim-illuminate") -- highlight same word under cursor

  -- use "jose-elias-alvarez/nvim-lsp-ts-utils"

  use {
    "folke/trouble.nvim",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("trouble").setup {}
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
      require "plugins.neo-tree"
    end
  }

  -- autocompletion snippets
  use "L3MON4D3/LuaSnip"
  use "saadparwaiz1/cmp_luasnip"
  use "rafamadriz/friendly-snippets"

  -- autocompletion
  use {
    "hrsh7th/nvim-cmp",
    config = function()
      require "plugins.nvim-cmp"
    end
  }

  use({ "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })

  -- treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require "plugins.treesitter"
    end
  }

  -- comments
  use {
    "numToStr/Comment.nvim",
    config = function()
      require "plugins.comment"
    end
  }

  -- todo comments
  use {
    "folke/todo-comments.nvim", -- special highlight  @TODO, @FIXME, etc comments
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
        filetype_exclude = {
          "alpha",
          "neo-tree",
          "lsp-installer",
          "packer",
          "dashboard"
        },
        space_char_blankline = " ",
        show_current_context = true,
        show_current_context_start = false,
        use_treesitter = true
      }
    end
  }

  -- use correct comments when there are multiple languages in 1 file, i.e. Vue SFC's
  use { "JoosepAlviste/nvim-ts-context-commentstring", after = "nvim-treesitter" }

  -- lualine (statusbar)
  use {
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require "plugins.lualine"
    end
  }

  -- bufferline (tabs)
  use {
    "akinsho/bufferline.nvim",
    tag = "*",
    config = function()
      require "plugins.bufferline"
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
    "rose-pine/neovim", -- current theme
    config = function()
      require "plugins.rose-pine"
    end
  })

  -- use {
  --   's1n7ax/nvim-window-picker',
  --   tag = 'v1.*',
  --   config = function()
  --     require "plugins.window-picker"
  --   end
  -- }

  use {
    "lewis6991/gitsigns.nvim", -- gutter git signs + git blame virtual text
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require "plugins.gitsigns"
    end
  }

  use {
    "norcalli/nvim-colorizer.lua", -- colorize hex codes / color names
    config = function()
      require("colorizer").setup({
        "*",
        css = { rgb_fn = true },
        html = { names = false }
      })
    end
  }

  use {
    "akinsho/toggleterm.nvim", -- terminal splits / floating windows
    config = function()
      require "plugins.toggleterm"
    end
  }

  use {
    "glepnir/dashboard-nvim", -- initial launch dashboard
    config = function()
      require "plugins.dashboard"
    end
  }

  use {
    "rcarriga/nvim-notify", -- floating toast notifications
    config = function()
      vim.notify = require("notify")
    end
  }

  -- use { 'wfxr/minimap.vim', run = ':!cargo install --locked code-minimap' }

  -- tpope plugins
  use { "tpope/vim-surround" } -- Change surrounding arks
  use { "tpope/vim-repeat" } -- extends . repeat

end)
