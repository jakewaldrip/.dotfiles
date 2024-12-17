local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Gruvbox Dark (Gogh)"

-- Blue Tone Dark Theme
-- config.color_scheme = "Catppuccin Mocha"

-- Light Theme
-- config.color_scheme = "Catppuccin Latte"

-- Slightly more solarized theme, use depending on vibe
-- config.color_scheme = "Lunaria Light (Gogh)"

-- Nord Theme
-- config.color_scheme = "nord"

config.font = wezterm.font("0xProto Nerd Font Mono")
config.font_size = 16

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.92
config.macos_window_background_blur = 10

-- Key bindings
local act = wezterm.action
config.keys = {
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = true }) },
}

-- and finally, return the configuration to wezterm
return config
