return {
  "rose-pine/neovim",
  name = "rose-pine",
  lazy = false,
  priority = 1000,
  opts = {
    variant = "main",
    dark_variant = "main",
    dim_inactive_windows = false,
    extend_background_behind_borders = true,
    enable = {
      terminal = true,
    },
    styles = {
      bold = true,
      italic = true,
      transparency = true,
    },
    highlight_groups = {
      NoiceCmdlinePopup = { fg = "text", bg = "highlight_low" },
      NoiceCmdlinePopupBorder = { fg = "overlay", bg = "highlight_low" },
      NoiceCmdlinePopupTitle = { fg = "subtle", bg = "highlight_low" },
      TelescopeNormal = { fg = "text", bg = "highlight_low" },
      TelescopeBorder = { fg = "overlay", bg = "highlight_low" },
      TelescopeTitle = { fg = "subtle", bg = "highlight_low" },
      TelescopePromptNormal = { fg = "text", bg = "highlight_low" },
      TelescopePromptBorder = { fg = "overlay", bg = "highlight_low" },
      TelescopePromptTitle = { fg = "subtle", bg = "highlight_low" },
      TelescopeResultsNormal = { fg = "text", bg = "highlight_low" },
      TelescopeResultsBorder = { fg = "overlay", bg = "highlight_low" },
      TelescopeResultsTitle = { fg = "subtle", bg = "highlight_low" },
      TelescopePreviewNormal = { fg = "text", bg = "highlight_low" },
      TelescopePreviewBorder = { fg = "overlay", bg = "highlight_low" },
      TelescopePreviewTitle = { fg = "subtle", bg = "highlight_low" },
    },
  },
  init = function()
    vim.cmd.colorscheme("rose-pine")
  end,
}
