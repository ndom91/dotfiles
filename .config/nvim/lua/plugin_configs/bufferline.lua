require("bufferline").setup {
  options = {
    indicator_icon = "▎",
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 25,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    tab_size = 25,
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "(" .. count .. ")"
    end,
    custom_areas = {
      right = function()
        local result = {}
        local error = vim.diagnostic.get_count(0, [[Error]])
        local warning = vim.diagnostic.get_count(0, [[Warning]])
        local info = vim.diagnostic.get_count(0, [[Information]])
        local hint = vim.diagnostic.get_count(0, [[Hint]])

        if error ~= 0 then
          result[1] = {
            text = "  " .. error,
            guifg = "#ff6c6b"
          }
        end

        if warning ~= 0 then
          result[2] = {
            text = "  " .. warning,
            guifg = "#ECBE7B"
          }
        end

        if hint ~= 0 then
          result[3] = {
            text = "  " .. hint,
            guifg = "#98be65"
          }
        end

        if info ~= 0 then
          result[4] = {
            text = "  " .. info,
            guifg = "#51afef"
          }
        end
        return result
      end
    },
    offsets = {
      {
        filetype = "NvimTree",
        text = function()
          return vim.fn.getcwd()
        end,
        text_align = "center"
      },
      {
        filetype = "vista",
        text = "Vista",
        text_align = "center"
      }
    },
    show_buffer_icons = true,
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = true,
    separator_style = "thin",
    enforce_regular_tabs = true,
    always_show_bufferline = true
  }
}
