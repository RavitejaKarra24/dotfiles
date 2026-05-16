local function prompt_from_terminal(colors, overrides)
  local prompt = {
    prompt_ok = colors.ansi[3],
    prompt_error = colors.ansi[2],
    dir = colors.ansi[5],
    dir_shortened = colors.brights[5],
    dir_anchor = colors.ansi[7],
    vcs_meta = colors.brights[1],
    vcs_clean = colors.ansi[3],
    vcs_modified = colors.ansi[4],
    vcs_untracked = colors.ansi[7],
    vcs_conflicted = colors.ansi[2],
    vcs_icon = colors.ansi[3],
    vcs_loading = colors.brights[1],
    status_ok = colors.ansi[3],
    status_error = colors.ansi[2],
    command_time = colors.ansi[6],
    background_jobs = colors.ansi[3],
    direnv = colors.ansi[4],
    asdf = colors.ansi[5],
  }

  for key, value in pairs(overrides or {}) do
    prompt[key] = value
  end

  return prompt
end

local function create_theme(opts)
  return {
    label = opts.label,
    nvim = opts.nvim,
    colors = opts.colors,
    prompt = prompt_from_terminal(opts.colors, opts.prompt),
  }
end

local themes = {
  coolnight = create_theme({
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
    prompt = {
      dir_anchor = "#24EAF7",
      vcs_untracked = "#0FC5ED",
      command_time = "#A277FF",
    },
  }),
  deep_ocean = create_theme({
    label = "Deep Ocean",
    nvim = "onedark",
    colors = {
      foreground = "#D4D4D4",
      background = "#0D1117",
      cursor_bg = "#58A6FF",
      cursor_border = "#58A6FF",
      cursor_fg = "#0D1117",
      selection_bg = "#264F78",
      selection_fg = "#D4D4D4",
      ansi = { "#21262D", "#F85149", "#7EE787", "#F2CC60", "#58A6FF", "#BC8CFF", "#39C5CF", "#B1BAC4" },
      brights = { "#484F58", "#FF7B72", "#56D364", "#E3B341", "#79C0FF", "#D2A8FF", "#56D4DD", "#F0F6FC" },
    },
  }),
  dracula = create_theme({
    label = "Dracula",
    nvim = "rose-pine",
    colors = {
      foreground = "#F8F8F2",
      background = "#1E1F29",
      cursor_bg = "#BD93F9",
      cursor_border = "#BD93F9",
      cursor_fg = "#1E1F29",
      selection_bg = "#44475A",
      selection_fg = "#F8F8F2",
      ansi = { "#21222C", "#FF5555", "#50FA7B", "#F1FA8C", "#BD93F9", "#FF79C6", "#8BE9FD", "#F8F8F2" },
      brights = { "#6272A4", "#FF6E6E", "#69FF94", "#FFFFA5", "#D6ACFF", "#FF92DF", "#A4FFFF", "#FFFFFF" },
    },
  }),
  gruvbox_dark = create_theme({
    label = "Gruvbox Dark",
    nvim = "gruvbox",
    colors = {
      foreground = "#EBDBB2",
      background = "#1D2021",
      cursor_bg = "#FE8019",
      cursor_border = "#FE8019",
      cursor_fg = "#1D2021",
      selection_bg = "#504945",
      selection_fg = "#EBDBB2",
      ansi = { "#1D2021", "#CC241D", "#98971A", "#D79921", "#458588", "#B16286", "#689D6A", "#A89984" },
      brights = { "#928374", "#FB4934", "#B8BB26", "#FABD2F", "#83A598", "#D3869B", "#8EC07C", "#EBDBB2" },
    },
  }),
  tokyo_night = create_theme({
    label = "Tokyo Night",
    nvim = "tokyonight-night",
    colors = {
      foreground = "#C0CAF5",
      background = "#1A1B26",
      cursor_bg = "#C0CAF5",
      cursor_border = "#C0CAF5",
      cursor_fg = "#1A1B26",
      selection_bg = "#33467C",
      selection_fg = "#C0CAF5",
      ansi = { "#1D202F", "#F7768E", "#9ECE6A", "#E0AF68", "#7AA2F7", "#BB9AF7", "#7DCFFF", "#A9B1D6" },
      brights = { "#414868", "#F7768E", "#9ECE6A", "#E0AF68", "#7AA2F7", "#BB9AF7", "#7DCFFF", "#C0CAF5" },
    },
  }),
  nord = create_theme({
    label = "Nord",
    nvim = "nord",
    colors = {
      foreground = "#D8DEE9",
      background = "#2E3440",
      cursor_bg = "#81A1C1",
      cursor_border = "#81A1C1",
      cursor_fg = "#2E3440",
      selection_bg = "#434C5E",
      selection_fg = "#D8DEE9",
      ansi = { "#3B4252", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#88C0D0", "#E5E9F0" },
      brights = { "#4C566A", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#8FBCBB", "#ECEFF4" },
    },
  }),
  one_dark_pro = create_theme({
    label = "One Dark Pro",
    nvim = "onedark",
    colors = {
      foreground = "#ABB2BF",
      background = "#1E2127",
      cursor_bg = "#528BFF",
      cursor_border = "#528BFF",
      cursor_fg = "#1E2127",
      selection_bg = "#3E4451",
      selection_fg = "#ABB2BF",
      ansi = { "#1E2127", "#E06C75", "#98C379", "#E5C07B", "#61AFEF", "#C678DD", "#56B6C2", "#ABB2BF" },
      brights = { "#5C6370", "#E06C75", "#98C379", "#E5C07B", "#61AFEF", "#C678DD", "#56B6C2", "#FFFFFF" },
    },
  }),
  catppuccin_mocha = create_theme({
    label = "Catppuccin Mocha",
    nvim = "catppuccin-mocha",
    colors = {
      foreground = "#CDD6F4",
      background = "#1E1E2E",
      cursor_bg = "#F5E0DC",
      cursor_border = "#F5E0DC",
      cursor_fg = "#1E1E2E",
      selection_bg = "#585B70",
      selection_fg = "#CDD6F4",
      ansi = { "#45475A", "#F38BA8", "#A6E3A1", "#F9E2AF", "#89B4FA", "#F5C2E7", "#94E2D5", "#BAC2DE" },
      brights = { "#585B70", "#F38BA8", "#A6E3A1", "#F9E2AF", "#89B4FA", "#F5C2E7", "#94E2D5", "#A6ADC8" },
    },
  }),
  arc_blueberry = create_theme({
    label = "Arc Blueberry",
    nvim = "tokyonight-night",
    colors = {
      foreground = "#BCC1DC",
      background = "#111422",
      cursor_bg = "#69C3FF",
      cursor_border = "#69C3FF",
      cursor_fg = "#111422",
      selection_bg = "#2A3150",
      selection_fg = "#BCC1DC",
      ansi = { "#111422", "#E35535", "#3CEC85", "#EACD61", "#8EB0E6", "#F38CEC", "#22ECDB", "#BCC1DC" },
      brights = { "#596180", "#FF7A5C", "#63F7A3", "#F4DE87", "#69C3FF", "#FFB2F7", "#66FFF1", "#E7EBFF" },
    },
  }),
  miasma = create_theme({
    label = "Miasma",
    nvim = "rose-pine",
    colors = {
      foreground = "#D7C483",
      background = "#222222",
      cursor_bg = "#C9A554",
      cursor_border = "#C9A554",
      cursor_fg = "#222222",
      selection_bg = "#3A3A32",
      selection_fg = "#D7C483",
      ansi = { "#222222", "#B36D43", "#809A34", "#C9A554", "#7E9CD8", "#B388B0", "#7CA6A6", "#D7C483" },
      brights = { "#585858", "#C7814A", "#95B84D", "#E1C26B", "#95B7F6", "#D7A7D2", "#9CCFD8", "#F3EAC2" },
    },
  }),
  city_783 = create_theme({
    label = "City 783",
    nvim = "onedark",
    colors = {
      foreground = "#C5C8D4",
      background = "#17191F",
      cursor_bg = "#E06C75",
      cursor_border = "#E06C75",
      cursor_fg = "#17191F",
      selection_bg = "#2B303B",
      selection_fg = "#C5C8D4",
      ansi = { "#17191F", "#E06C75", "#98C379", "#D19A66", "#61AFEF", "#C678DD", "#56B6C2", "#ABB2BF" },
      brights = { "#5C6370", "#F28B94", "#B5E08A", "#E5B27A", "#7BC3FF", "#D69DF2", "#73DACA", "#E5E9F0" },
    },
  }),
}

themes.order = {
  "coolnight",
  "deep_ocean",
  "dracula",
  "gruvbox_dark",
  "tokyo_night",
  "nord",
  "one_dark_pro",
  "catppuccin_mocha",
  "arc_blueberry",
  "miasma",
  "city_783",
}

return themes
