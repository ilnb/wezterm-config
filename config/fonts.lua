---@type Wezterm
local wezterm = require 'wezterm'
local platform = require 'utils.platform'

local font_family = 'Maple Mono'
-- local font_family = 'JetBrainsMono Nerd Font'
local font_size = 13
if require 'config.appearance'.enable_wayland then
  font_size = font_size - 4
end

---@type Config
return {
  font = wezterm.font {
    family = font_family,
    weight = 'Light',
  },
  font_size = font_size,

  --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
  freetype_load_target = 'Normal',
  freetype_render_target = 'Normal',
  warn_about_missing_glyphs = false,
}
