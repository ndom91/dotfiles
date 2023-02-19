local M = {}

function M.setup()
  local function lazy_init()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)
  end

  local plugins = {
    -- nerd font icons
    "nvim-tree/nvim-web-devicons",

    -- telescope
    "nvim-lua/plenary.nvim",
    "nvim-lua/popup.nvim",
    {
      "nvim-telescope/telescope.nvim",
      config = function()
        require "plugins.telescope"
      end
    },
    { "nvim-telescope/telescope-ui-select.nvim" },

    {
      "lvimuser/lsp-inlayhints.nvim",
      config = true
    },

    {
      'tami5/lspsaga.nvim',
      enabled = false,
      config = function()
        require "plugins.lsp.lsp-saga"
      end
    },

    "onsails/lspkind-nvim", -- icons on completion

    -- lsp function signature help on wildmenu
    {
      "ray-x/lsp_signature.nvim",
      config = function()
        local cfg = {
          hint_enable = false,
          bind = true,
          transparency = 30,
          handler_opts = { border = "rounded" }
        }
        require "lsp_signature".setup(cfg)
      end
    },

    {
      "zbirenbaum/copilot.lua",
      -- event = { "VimEnter" },
      event = { "BufRead" },
      dependencies = {
        'zbirenbaum/copilot-cmp'
      },
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
    },

    {
      "zbirenbaum/copilot-cmp",
      module = "copilot_cmp",
    },

    {
      "j-hui/fidget.nvim", -- floating status text in bottom right
      config = function()
        require("plugins.fidget-nvim")
      end
    },

    {
      "folke/trouble.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("trouble").setup {}
      end
    },

    "folke/neodev.nvim",

    -- UI Elements
    "MunifTanjim/nui.nvim",

    -- Tailwind token colorizer
    {
      'mrshmllow/document-color.nvim',
      enabled = false,
      config = function()
        local docColors = require("document-color")
        docColors.setup { mode = "background" }
        docColors.buf_attach()
      end
    },

    -- terminal image viewer
    {
      'edluffy/hologram.nvim',
      enabled = false,
      config = function()
        require("hologram").setup { auto_display = true }
      end
    },

    -- neo tree
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v2.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim"
      },
      config = function()
        require "plugins.neo-tree"
      end
    },

    -- autocompletion
    {
      "hrsh7th/nvim-cmp",
      config = true,
      -- wants = { "LuaSnip" },
      dependencies = {
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
    },

    -- AI completion
    { "github/copilot.vim",
      event = "InsertEnter",
      enabled = false
    },

    -- lsp-zero
    {
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v1.x',
      dependencies = {
        -- LSP Support
        { 'neovim/nvim-lspconfig' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
        { "lvimuser/lsp-inlayhints.nvim" },
        { 'b0o/schemastore.nvim' },

        -- Autocompletion
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-path' },
        { 'saadparwaiz1/cmp_luasnip' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-nvim-lua' },

        -- Snippets
        { 'L3MON4D3/LuaSnip' },
        { 'rafamadriz/friendly-snippets' },

        -- Languages
        { 'jose-elias-alvarez/typescript.nvim' }

      },
      config = function()
        local lsp = require('lsp-zero').preset({
          name = 'recommended',
        })
        lsp.nvim_workspace()
        lsp.setup_nvim_cmp({
          sources = {
            { name = "copilot" },
            {
              name = "nvim_lsp",
              max_item_count = 10
            },
            { name = "nvim_lsp_signature_help" },
            { name = "luasnip" },
            { name = "treesitter" },
            {
              name = "buffer",
              max_item_count = 5
            },
            { name = "path" },
            { name = "nvim_lua" }
          },
          format = function(entry, vim_item)
            -- Kind icons
            -- vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind],
            --                               vim_item.kind) -- This concatonates the icons with the name of the item kind

            -- copilot
            if entry.source.name == "copilot" then
              vim_item.kind = "[] Copilot"
              vim_item.kind_hl_group = "CmpItemKindCopilot"
              return vim_item
            end

            -- Source
            vim_item.menu = ({
                  nvim_lsp = "[LSP]",
                  luasnip = "[Snip]",
                  buffer = "[Buffer]",
                  nvim_lua = "[Lua]",
                  treesitter = "[Treesitter]",
                  path = "[Path]",
                  nvim_lsp_signature_help = "[Signature]"
                })[entry.source.name]

            return vim_item
          end
        })

        lsp.ensure_installed({
          'tsserver',
          'html',
          'jsonls',
          'dockerls',
          'bashls',
          'vimls',
          'tailwindcss',
          'lua_ls',
          'cssls',
          'volar',
          'yamlls',
        })

        lsp.configure('jsonls', {
          settings = { json = { schemas = require("schemastore").json.schemas() } }
        })

        lsp.configure('yamlls', {
          schemastore = { enable = true },
          settings = {
            yaml = {
              hover = true,
              completion = true,
              validate = true,
              schemas = require("schemastore").json.schemas()
            }
          }
        })

        lsp.configure('tsserver', {
          disable_formatting = true,
          settings = {
            javascript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true
              }
            },
            typescript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true
              }
            }
          }
        })

        lsp.on_attach(function(client, bufnr)
          local opts = { buffer = bufnr }
          local bind = vim.keymap.set

          bind('n', '<leader>lf', '<cmd>LspZeroFormat<cr>', opts)
          bind('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          bind('n', '<leader>re', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
          -- more keybindings...
        end)

        lsp.setup()
      end
    },

    -- use "jose-elias-alvarez/typescript.nvim"

    -- treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require "plugins.treesitter"
      end
    },
    { 'nvim-treesitter/nvim-treesitter-context' },
    { 'JoosepAlviste/nvim-ts-context-commentstring' },

    -- comments
    {
      "numToStr/Comment.nvim",
      config = function()
        require "plugins.comment"
      end
    },

    -- todo comments
    {
      "folke/todo-comments.nvim", -- special highlight  @TODO, @FIXME, etc comments
      dependencies = "nvim-lua/plenary.nvim",
      config = function()
        require "plugins.todo-comments"
      end
    },

    -- indent
    {
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
    },

    -- lualine (statusbar)
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require "plugins.lualine"
      end
    },

    -- bufferline (tabs)
    {
      "akinsho/bufferline.nvim",
      version = "v3.*",
      lazy = false,
      keys = {
        { "<c-x>",   '<cmd>lua require("bufferline").handle_close(vim.fn.bufnr("%"))<CR>', desc = "Bufferline Close" },
        { "<Tab>",   ":bnext<CR>" },
        { "<S-Tab>", ":bprev<CR>" }
      },
      config = function()
        require "plugins.bufferline"
      end
    },

    -- theme
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
      "rose-pine/neovim", -- current theme
      lazy = false, -- load first
      priority = 1000, -- before anything else
      config = function()
        require "plugins.rose-pine"
      end
    },

    -- use {
    --   's1n7ax/nvim-window-picker',
    --   version = 'v1.*',
    --   config = function()
    --     require "plugins.window-picker"
    --   end
    -- }

    {
      "lewis6991/gitsigns.nvim", -- gutter git signs + git blame virtual text
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require "plugins.gitsigns"
      end
    },

    {
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
    },

    {
      "akinsho/toggleterm.nvim", -- terminal splits / floating windows
      config = function()
        require "plugins.toggleterm"
      end
    },

    {
      "glepnir/dashboard-nvim", -- initial launch dashboard
      event = 'VimEnter',
      config = function()
        require('dashboard').setup {
          theme = 'hyper',
          config = {
            week_header = {
              enable = true,
            },
            shortcut = {
              { desc = ' Update', group = '@property', action = 'Lazy update', key = 'u' },
              {
                icon = ' ',
                icon_hl = '@variable',
                desc = 'Files',
                group = 'Label',
                action = 'Telescope find_files',
                key = 'f',
              },
              {
                desc = ' Apps',
                group = 'DiagnosticHint',
                action = 'Telescope app',
                key = 'a',
              },
              {
                desc = ' dotfiles',
                group = 'Number',
                action = 'Telescope dotfiles',
                key = 'd',
              },
            }, },
        }
      end,
      dependencies = { 'nvim-tree/nvim-web-devicons' }
    },

    -- Notification
    {
      "rcarriga/nvim-notify",
      config = true,
    },
    --[[ use { ]]
    --[[   "rcarriga/nvim-notify", -- floating toast notifications ]]
    --[[   config = function() ]]
    --[[     vim.notify = require "plugins.notify" ]]
    --[[   end ]]
    --[[ } ]]
    -- use { 'wfxr/minimap.vim', build = ':!cargo install --locked code-minimap' }

    -- tpope plugins
    { "tpope/vim-surround" }, -- Change surrounding arks
    { "tpope/vim-repeat" }, -- extends . repeat
  }

  -- Init and start packer
  lazy_init()
  local lazy = require "lazy"

  lazy.setup(plugins, opts)
end

return M
