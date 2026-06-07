return {
  "scottmckendry/cyberdream.nvim",
  enabled = false,
  lazy = false,
  priority = 1000,
  opts = {
    variant = "dark",
    transparent = true,
    italic_comments = true,
    borderless_pickers = true,
    terminal_colors = true,
    extensions = {
      gitsigns = true,
      lazy = true,
      noice = true,
      notify = true,
      treesitter = true,
      treesittercontext = true,
      trouble = true,
    },
  },
  init = function()
    vim.cmd.colorscheme("cyberdream")
  end,
}
