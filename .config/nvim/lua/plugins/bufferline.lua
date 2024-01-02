local symbol_map = {
  error = "",
  warning = "",
  info = "",
  hint = "",
}

return {
  "akinsho/bufferline.nvim",
  version = "v4.*",
  event = "VimEnter",
  keys = {
    {
      "<c-x>",
      "<cmd>bd<CR>",
      desc = "Bufferline Close",
      silent = true
    },
    { "<Tab>",   ":bnext<CR>", silent = true },
    { "<S-Tab>", ":bprev<CR>", silent = true },
  },
  opts = {
    options = {
      -- indicator = { icon = "▎" },
      buffer_close_icon = "",
      modified_icon = "●",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      right_mouse_command = "bdelete! %d",
      max_name_length = 25,
      max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
      truncate_names = true,
      tab_size = 22,
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(total_count, level, diagnostics_dict)
        local s = ""
        for kind, count in pairs(diagnostics_dict) do
          s = string.format("%s %s %d", s, symbol_map[kind], count)
        end
        return s
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = function()
            return vim.fn.getcwd()
          end,
          text_align = "center",
        },
      },
      color_icons = true,
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
      show_tab_indicators = true,
      separator_style = "thin", -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
      enforce_regular_tabs = false,
      always_show_bufferline = true,
    },
  }
}
