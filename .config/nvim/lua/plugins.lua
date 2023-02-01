local M = {}

function M.setup()
  -- Indicate first time installation
  local packer_bootstrap = false

  -- packer.nvim configuration
  local conf = {
    profile = {
      enable = true,
      threshold = 0 -- the amount in ms that a plugins load time must be over for it to be included in the profile
    },

    display = {
      open_fn = function()
        return require("packer.util").float { border = "rounded" }
      end
    }
  }

  -- Check if packer.nvim is installed
  -- Run PackerCompile if there are changes in this file
  local function packer_init()
    local fn = vim.fn
    local install_path = fn.stdpath "data" ..
                             "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
      packer_bootstrap = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path
      }
      vim.cmd [[packadd packer.nvim]]
    end

    -- Run PackerCompile if there are changes in this file
    -- vim.cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
    local packer_grp = vim.api.nvim_create_augroup("packer_user_config",
                                                   { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      pattern = "init.lua",
      command = "source <afile> | PackerCompile",
      group = packer_grp
    })
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

    -- use "jose-elias-alvarez/nvim-lsp-ts-utils"
    --
    use {
      "lvimuser/lsp-inlayhints.nvim",
      config = function()
        require("lsp-inlayhints").setup()
      end
    }

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

    use {
      "zbirenbaum/copilot.lua",
      event = { "VimEnter" },
      config = function()
        vim.defer_fn(function()
          require("copilot").setup {
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
                "notify"
              }
            }
          }
        end, 100)
      end
    }
    use {
      "zbirenbaum/copilot-cmp",
      module = "copilot_cmp",
      after = "copilot.lua"
    }

    use({
      "j-hui/fidget.nvim", -- floating status text in bottom right
      config = function()
        require("plugins.fidget-nvim")
      end
    })

    use {
      "folke/trouble.nvim",
      requires = { "kyazdani42/nvim-web-devicons" },
      config = function()
        require("trouble").setup {}
      end
    }

    -- UI Elements
    use "MunifTanjim/nui.nvim"

    -- Tailwind token colorizer
    use {
      'mrshmllow/document-color.nvim',
      config = function()
        docColors = require("document-color")
        docColors.setup { mode = "background" }
        docColors.buf_attach()
      end
    }

    -- neo tree
    use {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v2.x",
      requires = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons",
        "MunifTanjim/nui.nvim"
      },
      config = function()
        require "plugins.neo-tree"
      end
    }

    -- autocompletion
    use {
      "hrsh7th/nvim-cmp",
      config = function()
        require("plugins.nvim-cmp").setup()
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

    -- AI completion
    use { "github/copilot.vim", event = "InsertEnter", disable = true }

    -- lsp
    use {
      "neovim/nvim-lspconfig",
      config = function()
        require("plugins.lsp").setup()
      end,
      wants = {
        "mason.nvim",
        "mason-lspconfig.nvim",
        "mason-tool-install.nvim",
        "cmp-nvim-lsp",
        "null-ls.nvim",
        "typescript.nvim",
        "lsp-inlayhints"
      },
      requires = {
        "jose-elias-alvarez/null-ls.nvim",
        {
          "j-hui/fidget.nvim",
          config = function()
            require("fidget").setup {}
          end
        },
        "b0o/schemastore.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "jose-elias-alvarez/typescript.nvim"
      }
    }

    use "jose-elias-alvarez/typescript.nvim"

    -- treesitter
    use {
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      config = function()
        require "plugins.treesitter"
      end
    }
    use { 'nvim-treesitter/nvim-treesitter-context' }
    use { 'JoosepAlviste/nvim-ts-context-commentstring' }

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
        require "plugins.todo-comments"
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
      tag = "v2.*",
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
          -- css = { rgb_fn = true }, -- disabled in favor of document-color
          -- html = { names = false },
          '!css',
          '!html',
          '!tsx',
          '!dart'
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

    -- Notification
    use {
      "rcarriga/nvim-notify",
      --[[ event = "BufReadPre", ]]
      config = function()
        require("plugins.notify").setup()
      end
      --[[ disable = false, ]]
    }
    --[[ use { ]]
    --[[   "rcarriga/nvim-notify", -- floating toast notifications ]]
    --[[   config = function() ]]
    --[[     vim.notify = require "plugins.notify" ]]
    --[[   end ]]
    --[[ } ]]

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
