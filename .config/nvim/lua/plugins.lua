-- vim.cmd([[
--   augroup packer_user_config
--     autocmd!
--     autocmd BufWritePost plugins.lua source <afile> | PackerCompile
--   augroup end
-- ]])
--
-- local packer = require("packer")
--
-- packer.init({
--   git = {
--     clone_timeout = 300,
--     subcommands = { install = "clone --depth %i --progress" }
--   },
--   profile = { enable = true }
-- })

local M = {}

function M.setup()
  -- Indicate first time installation
  local packer_bootstrap = false

  -- packer.nvim configuration
  local conf = {
    profile = {
      enable = true,
      threshold = 0, -- the amount in ms that a plugins load time must be over for it to be included in the profile
    },

    display = {
      open_fn = function()
        return require("packer.util").float { border = "rounded" }
      end,
    },
  }

  -- Check if packer.nvim is installed
  -- Run PackerCompile if there are changes in this file
  local function packer_init()
    local fn = vim.fn
    local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
      packer_bootstrap = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
      }
      vim.cmd [[packadd packer.nvim]]
    end

    -- Run PackerCompile if there are changes in this file
    -- vim.cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
    local packer_grp = vim.api.nvim_create_augroup("packer_user_config", { clear = true })
    vim.api.nvim_create_autocmd(
      { "BufWritePost" },
      { pattern = "init.lua", command = "source <afile> | PackerCompile", group = packer_grp }
    )
  end

local function plugins(use)
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
      -- require "plugins.lsp.lsp-config"
      require("plugins.lsp").setup()
    end,
    wants = {
      "cmp-nvim-lsp",
      "null-ls.nvim",
      "vim-illuminate"
    },
    requires = {
      "rrethy/vim-illuminate",
      "jose-elias-alvarez/null-ls.nvim",
        {
          "j-hui/fidget.nvim",
          config = function()
            require("fidget").setup {}
          end,
        },
        "b0o/schemastore.nvim",
    }
  }

  -- use "lvimuser/lsp-inlayhints.nvim"
  -- use "b0o/schemastore.nvim"

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

  -- use({
  --   "jose-elias-alvarez/null-ls.nvim",
  --   -- config = function()
  --   --   require("plugins.lsp.nll-ls")
  --   -- end,
  --   requires = { "nvim-lua/plenary.nvim" }
  -- })

  use({
    "j-hui/fidget.nvim", -- floating status text in bottom right
    config = function()
      require("plugins.fidget-nvim")
    end
  })

  -- use("rrethy/vim-illuminate") -- highlight same word under cursor

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
  -- use "L3MON4D3/LuaSnip"
  -- use "saadparwaiz1/cmp_luasnip"
  -- use "rafamadriz/friendly-snippets"

  -- autocompletion
  use {
    "hrsh7th/nvim-cmp",
    config = function()
      require "plugins.nvim-cmp"
    end,
    wants = { "LuaSnip" },
    requires = {
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip"
    }
  }

  -- use({ "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-nvim-lsp" })
  -- use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })

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


    -- Bootstrap Neovim
    if packer_bootstrap then
      print "Neovim restart is required after installation!"
      require("packer").sync()
    end
  end

  -- Init and start packer
  packer_init()
  local packer = require "packer"

  -- Performance
  pcall(require, "impatient")
  -- pcall(require, "packer_compiled")

  packer.init(conf)
  packer.startup(plugins)
end

return M
