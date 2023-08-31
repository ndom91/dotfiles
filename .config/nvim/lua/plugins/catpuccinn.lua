return {
  "m4xshen/catppuccinight.nvim",
  enabled = "true",
  name = "catppuccin",
  opts = {
    flavour = "mocha",
    transparent_background = true,
    term_colors = true,
    integration = {
      cmp = true,
      gitsigns = true,
      treesitter = true,
      notify = true,
      mini = false,
      indent_blankline = {
        enabled = true,
      },
      neotree = true,
      lsp_trouble = true,
    },
    custom_highlights = function(colors)
      return {
        VertSplit = { fg = colors.surface0 },
        TelescopeBorder = { fg = colors.mantle, bg = colors.mantle },
        TelescopeSelectionCaret = { fg = colors.lavender, bg = colors.mantle },
        TelescopeMatching = { fg = colors.yellow },
        TelescopeNormal = { bg = colors.mantle },
        TelescopeSelection = { fg = colors.text, bg = colors.mantle },
        TelescopeMultiSelection = { fg = colors.text, bg = colors.mantle },

        TelescopeTitle = { fg = colors.overlay0, bg = colors.lavender },
        TelescopePreviewTitle = { fg = colors.overlay0, bg = colors.lavender },
        TelescopePromptTitle = { fg = colors.overlay0, bg = colors.lavender },

        TelescopePromptPrefix = { fg = colors.lavender },
        TelescopePromptNormal = { fg = colors.text, bg = colors.surface1 },
        TelescopePromptBorder = { fg = colors.surface1, bg = colors.surface1 },

        -- Customization for Pmenu

        PmenuSel = { bg = "#282C34", fg = "NONE" },
        -- PmenuSel = { bg = colors.overlay0, fg = "NONE" },
        Pmenu = { fg = "#C5CDD9", bg = colors.mantle },
        -- Pmenu = { fg = colors.text, bg = colors.surface1 },
        NormalFloat = { fg = colors.text, bg = colors.mantle },
        FloatBorder = { fg = colors.text, bg = colors.mantle },
        FloatShadow = { fg = colors.text, bg = "NONE" },
        FloatShadowThrough = { fg = colors.text, bg = "NONE" },

				CmpItemKindSnippet = { fg = colors.base, bg = colors.mauve },
				CmpItemKindKeyword = { fg = colors.base, bg = colors.red },
				CmpItemKindText = { fg = colors.base, bg = colors.teal },
				CmpItemKindMethod = { fg = colors.base, bg = colors.blue },
				CmpItemKindConstructor = { fg = colors.base, bg = colors.blue },
				CmpItemKindFunction = { fg = colors.base, bg = colors.blue },
				CmpItemKindFolder = { fg = colors.base, bg = colors.blue },
				CmpItemKindModule = { fg = colors.base, bg = colors.blue },
				CmpItemKindConstant = { fg = colors.base, bg = colors.peach },
				CmpItemKindField = { fg = colors.base, bg = colors.green },
				CmpItemKindProperty = { fg = colors.base, bg = colors.green },
				CmpItemKindEnum = { fg = colors.base, bg = colors.green },
				CmpItemKindUnit = { fg = colors.base, bg = colors.green },
				CmpItemKindClass = { fg = colors.base, bg = colors.yellow },
				CmpItemKindVariable = { fg = colors.base, bg = colors.flamingo },
				CmpItemKindFile = { fg = colors.base, bg = colors.blue },
				CmpItemKindInterface = { fg = colors.base, bg = colors.yellow },
				CmpItemKindColor = { fg = colors.base, bg = colors.red },
				CmpItemKindReference = { fg = colors.base, bg = colors.red },
				CmpItemKindEnumMember = { fg = colors.base, bg = colors.red },
				CmpItemKindStruct = { fg = colors.base, bg = colors.blue },
				CmpItemKindValue = { fg = colors.base, bg = colors.peach },
				CmpItemKindEvent = { fg = colors.base, bg = colors.blue },
				CmpItemKindOperator = { fg = colors.base, bg = colors.blue },
				CmpItemKindTypeParameter = { fg = colors.base, bg = colors.blue },
				CmpItemKindCopilot = { fg = colors.base, bg = colors.teal },

        -- CmpItemAbbrDeprecated = {
        --   fg = "#7E8294",
        --   bg = "NONE",
        --   strikethrough = true,
        -- },
        -- CmpItemAbbr = { fg = "NONE", bg = colors.mantle },
        CmpItemMenu = { fg = "#C792EA", bg = "NONE", italic = true },
        CmpItemMenuDefault = { fg = "#C792EA", bg = "NONE", italic = true },
        -- CmpItemKind = { fg = "NONE", bg = colors.mantle },
        --
        -- CmpItemKindField = { fg = "#EED8DA", bg = "#B5585F" },
        -- CmpItemKindProperty = { fg = "#EED8DA", bg = "#B5585F" },
        -- CmpItemKindEvent = { fg = "#EED8DA", bg = "#B5585F" },
        --
        -- CmpItemKindText = { fg = "#C3E88D", bg = "#9FBD73" },
        -- CmpItemKindEnum = { fg = "#C3E88D", bg = "#9FBD73" },
        -- CmpItemKindKeyword = { fg = "#C3E88D", bg = "#9FBD73" },
        --
        -- CmpItemKindConstant = { fg = "#FFE082", bg = "#D4BB6C" },
        -- CmpItemKindConstructor = { fg = "#FFE082", bg = "#D4BB6C" },
        -- CmpItemKindReference = { fg = "#FFE082", bg = "#D4BB6C" },
        --
        -- CmpItemKindFunction = { fg = "#EADFF0", bg = "#A377BF" },
        -- CmpItemKindStruct = { fg = "#EADFF0", bg = "#A377BF" },
        -- CmpItemKindClass = { fg = "#EADFF0", bg = "#A377BF" },
        -- CmpItemKindModule = { fg = "#EADFF0", bg = "#A377BF" },
        -- CmpItemKindOperator = { fg = "#EADFF0", bg = "#A377BF" },
        --
        -- CmpItemKindVariable = { fg = "#C5CDD9", bg = "#7E8294" },
        -- CmpItemKindFile = { fg = "#C5CDD9", bg = "#7E8294" },
        --
        -- CmpItemKindUnit = { fg = "#F5EBD9", bg = "#D4A959" },
        -- CmpItemKindSnippet = { fg = "#F5EBD9", bg = "#D4A959" },
        -- CmpItemKindFolder = { fg = "#F5EBD9", bg = "#D4A959" },
        --
        -- CmpItemKindMethod = { fg = "#DDE5F5", bg = "#6C8ED4" },
        -- CmpItemKindValue = { fg = "#DDE5F5", bg = "#6C8ED4" },
        -- CmpItemKindEnumMember = { fg = "#DDE5F5", bg = "#6C8ED4" },
        --
        -- CmpItemKindInterface = { fg = "#D8EEEB", bg = "#58B5A8" },
        -- CmpItemKindColor = { fg = "#D8EEEB", bg = "#58B5A8" },
        -- CmpItemKindTypeParameter = { fg = "#D8EEEB", bg = "#58B5A8" },
      }
    end,
  },
  init = function()
    vim.cmd.colorscheme("catppuccin")
  end,
}
