local wezterm = require 'wezterm'

local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.default_prog = { '/bin/tmux', 'new-session' }

-- For example, changing the color scheme:
config.color_scheme = 'Catppuccin Mocha (Gogh)'
-- config.color_scheme = 'Tokyo Night (Gogh)'
config.window_background_opacity = 0.9

config.font = wezterm.font_with_fallback {
  { family = 'Operator Mono', weight = 'Light', harfbuzz_features = { 'liga=1' } },
  'Fira Code',
  'Ubuntu Mono',
}
config.font_size = 10.0

config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
  left = 4,
  right = 4,
  top = 2,
  bottom = 0,
}

config.keys = {
  {
    key = 'r',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ReloadConfiguration,
  },
  { key = ' ', mods = 'CTRL|SHIFT', action = wezterm.action.QuickSelect },

}

return config

