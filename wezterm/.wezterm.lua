-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- my coolnight colorscheme
config.colors = {
    foreground = "#CBE0F0",
    background = "#011423",
    cursor_bg = "#47FF9C",
    cursor_border = "#47FF9C",
    cursor_fg = "#011423",
    selection_bg = "#033259",
    selection_fg = "#CBE0F0",
    ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
    brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

-- 1. Deep Ocean (Cool Blue-Gray)
-- config.colors = {
-- 	foreground = "#D4D4D4",
-- 	background = "#0D1117",
-- 	cursor_bg = "#58A6FF",
-- 	cursor_border = "#58A6FF",
-- 	cursor_fg = "#0D1117",
-- 	selection_bg = "#264F78",
-- 	selection_fg = "#D4D4D4",
-- 	ansi = { "#21262D", "#F85149", "#7EE787", "#F2CC60", "#58A6FF", "#BC8CFF", "#39C5CF", "#B1BAC4" },
-- 	brights = { "#484F58", "#FF7B72", "#56D364", "#E3B341", "#79C0FF", "#D2A8FF", "#56D4DD", "#F0F6FC" },
-- }

-- 2. Dracula Inspired (Purple & Pink)
-- config.colors = {
-- 	foreground = "#F8F8F2",
-- 	background = "#1E1F29",
-- 	cursor_bg = "#BD93F9",
-- 	cursor_border = "#BD93F9",
-- 	cursor_fg = "#1E1F29",
-- 	selection_bg = "#44475A",
-- 	selection_fg = "#F8F8F2",
-- 	ansi = { "#21222C", "#FF5555", "#50FA7B", "#F1FA8C", "#BD93F9", "#FF79C6", "#8BE9FD", "#F8F8F2" },
-- 	brights = { "#6272A4", "#FF6E6E", "#69FF94", "#FFFFA5", "#D6ACFF", "#FF92DF", "#A4FFFF", "#FFFFFF" },
-- }

-- 3. Gruvbox Dark (Warm Retro)
-- config.colors = {
-- 	foreground = "#EBDBB2",
-- 	background = "#1D2021",
-- 	cursor_bg = "#FE8019",
-- 	cursor_border = "#FE8019",
-- 	cursor_fg = "#1D2021",
-- 	selection_bg = "#504945",
-- 	selection_fg = "#EBDBB2",
-- 	ansi = { "#1D2021", "#CC241D", "#98971A", "#D79921", "#458588", "#B16286", "#689D6A", "#A89984" },
-- 	brights = { "#928374", "#FB4934", "#B8BB26", "#FABD2F", "#83A598", "#D3869B", "#8EC07C", "#EBDBB2" },
-- }

-- 4. Tokyo Night (Modern Dark Purple)
-- config.colors = {
-- 	foreground = "#C0CAF5",
-- 	background = "#1A1B26",
-- 	cursor_bg = "#C0CAF5",
-- 	cursor_border = "#C0CAF5",
-- 	cursor_fg = "#1A1B26",
-- 	selection_bg = "#33467C",
-- 	selection_fg = "#C0CAF5",
-- 	ansi = { "#1D202F", "#F7768E", "#9ECE6A", "#E0AF68", "#7AA2F7", "#BB9AF7", "#7DCFFF", "#A9B1D6" },
-- 	brights = { "#414868", "#F7768E", "#9ECE6A", "#E0AF68", "#7AA2F7", "#BB9AF7", "#7DCFFF", "#C0CAF5" },
-- }

-- 5. Nord (Arctic Blue-Gray)
-- config.colors = {
-- 	foreground = "#D8DEE9",
-- 	background = "#2E3440",
-- 	cursor_bg = "#81A1C1",
-- 	cursor_border = "#81A1C1",
-- 	cursor_fg = "#2E3440",
-- 	selection_bg = "#434C5E",
-- 	selection_fg = "#D8DEE9",
-- 	ansi = { "#3B4252", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#88C0D0", "#E5E9F0" },
-- 	brights = { "#4C566A", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#8FBCBB", "#ECEFF4" },
-- }

--6. One Dark Pro (VSCode Dark)
-- config.colors = {
-- 	foreground = "#ABB2BF",
-- 	background = "#1E2127",
-- 	cursor_bg = "#528BFF",
-- 	cursor_border = "#528BFF",
-- 	cursor_fg = "#1E2127",
-- 	selection_bg = "#3E4451",
-- 	selection_fg = "#ABB2BF",
-- 	ansi = { "#1E2127", "#E06C75", "#98C379", "#E5C07B", "#61AFEF", "#C678DD", "#56B6C2", "#ABB2BF" },
-- 	brights = { "#5C6370", "#E06C75", "#98C379", "#E5C07B", "#61AFEF", "#C678DD", "#56B6C2", "#FFFFFF" },
-- }

-- 7. Catppuccin Mocha (Pastel Dark)
-- config.colors = {
-- 	foreground = "#CDD6F4",
-- 	background = "#1E1E2E",
-- 	cursor_bg = "#F5E0DC",
-- 	cursor_border = "#F5E0DC",
-- 	cursor_fg = "#1E1E2E",
-- 	selection_bg = "#585B70",
-- 	selection_fg = "#CDD6F4",
-- 	ansi = { "#45475A", "#F38BA8", "#A6E3A1", "#F9E2AF", "#89B4FA", "#F5C2E7", "#94E2D5", "#BAC2DE" },
-- 	brights = { "#585B70", "#F38BA8", "#A6E3A1", "#F9E2AF", "#89B4FA", "#F5C2E7", "#94E2D5", "#A6ADC8" },
-- }



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
