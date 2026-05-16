-- Pull in the wezterm API
local wezterm = require("wezterm")

local function load_themes()
  local theme_files = {
    wezterm.config_dir .. "/.config/wezterm/themes.lua",
    os.getenv("HOME") .. "/.dotfiles/wezterm/.config/wezterm/themes.lua",
  }

  for _, theme_file in ipairs(theme_files) do
    local ok, loaded_themes = pcall(dofile, theme_file)
    if ok and type(loaded_themes) == "table" then
      return loaded_themes
    end
  end

  wezterm.log_error("Could not load external theme library, falling back to built-in coolnight theme")

  return {
    coolnight = {
      label = "Coolnight",
      nvim = "tokyonight-night",
      colors = {
        foreground = "#CBE0F0",
        background = "#011423",
        cursor_bg = "#47FF9C",
        cursor_border = "#47FF9C",
        cursor_fg = "#011423",
        selection_bg = "#033259",
        selection_fg = "#CBE0F0",
        ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
        brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
      },
    },
  }
end

-- This will hold the configuration.
local config = wezterm.config_builder()
local themes = load_themes()
local active_theme = "deep_ocean"
local fallback_theme = "coolnight"

-- This is where you actually apply your config choices
local color_schemes = {}
for name, theme in pairs(themes) do
  if type(theme) == "table" and theme.colors then
    color_schemes[name] = theme.colors
  end
end

if not color_schemes[active_theme] then
  wezterm.log_error("Unknown WezTerm theme '" .. active_theme .. "', falling back to '" .. fallback_theme .. "'")
  active_theme = fallback_theme
end

config.color_schemes = color_schemes
config.color_scheme = active_theme
config.set_environment_variables = {
  DOTFILES_THEME = active_theme,
}

-- Change only this value to switch themes:
-- coolnight, deep_ocean, dracula, gruvbox_dark, tokyo_night, nord,
-- one_dark_pro, catppuccin_mocha, arc_blueberry, miasma, city_783



config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 19

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.7
config.macos_window_background_blur = 10
-- Distribute extra pixels evenly so there's no gap on right/bottom edges
-- Using "0cell" means zero explicit padding, but WezTerm will still
-- distribute sub-cell leftover pixels evenly across both sides
config.window_padding = {
    left = 4,
    right = 0,
    top = 0,
    bottom = 0,
}

config.adjust_window_size_when_changing_font_size = false

-- and finally, return the configuration to wezterm
return config
