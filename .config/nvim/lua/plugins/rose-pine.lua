return {
  "rose-pine/neovim", -- current theme
  name = "rose-pine",
  lazy = false, -- load first
  priority = 1000, -- before anything else
  config = function()
    require("rose-pine").setup({
      ---@usage 'main'|'moon'
      dark_variant = "main",
      bold_vert_split = true,
      dim_nc_background = false,
      disable_background = false,
      disable_float_background = false,
      disable_italics = false,
      ---@usage string hex value or named color from rosepinetheme.com/palette
      groups = {
        border = "highlight_med",
        comment = "muted",
        link = "iris",
        punctuation = "subtle",
        error = "love",
        hint = "iris",
        info = "foam",
        warn = "gold",
        headings = {
          h1 = "iris",
          h2 = "foam",
          h3 = "rose",
          h4 = "gold",
          h5 = "pine",
          h6 = "foam",
        },
        git_add = "pine",
        git_delete = "love",
        git_change = "rose",
        git_dirty = "rose",
        git_ignore = "muted",
        git_merge = "iris",
        git_rename = "pine",
        git_stage = "iris",
        git_text = "rose",
        -- or set all headings at once
        -- headings = 'subtle'
      },
      highlight_groups = {
        TelescopeBorder = { fg = "surface", bg = "surface" },
        TelescopeSelectionCaret = { fg = "iris", bg = "overlay" },
        TelescopeMatching = { fg = "gold" },
        TelescopeNormal = { bg = "surface" },
        TelescopeSelection = { fg = "text", bg = "overlay" },
        TelescopeMultiSelection = { fg = "text", bg = "overlay" },

        TelescopeTitle = { fg = "base", bg = "iris" },
        TelescopePreviewTitle = { fg = "base", bg = "iris" },
        TelescopePromptTitle = { fg = "base", bg = "iris" },

        TelescopePromptPrefix = { fg = "iris" },
        TelescopePromptNormal = { fg = "text", bg = "muted" },
        TelescopePromptBorder = { fg = "muted", bg = "muted" },
      },
    })

    -- set colorscheme after options
    vim.cmd("colorscheme rose-pine")
  end,
}
