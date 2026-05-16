typeset -ga _dotfiles_theme_files
_dotfiles_theme_files=(
  "$HOME/.config/wezterm/themes.lua"
  "$HOME/.dotfiles/wezterm/.config/wezterm/themes.lua"
)

typeset -ga _dotfiles_wezterm_files
_dotfiles_wezterm_files=(
  "$HOME/.wezterm.lua"
  "$HOME/.dotfiles/wezterm/.wezterm.lua"
)

if [[ -z ${DOTFILES_THEME:-} ]]; then
  typeset config_file
  for config_file in "${_dotfiles_wezterm_files[@]}"; do
    [[ -r "$config_file" ]] || continue
    DOTFILES_THEME="$(sed -nE 's/^[[:space:]]*local active_theme = "([^"]+)".*$/\1/p' "$config_file" | sed -n '1p')"
    [[ -n "$DOTFILES_THEME" ]] && break
  done
fi

: "${DOTFILES_THEME:=coolnight}"
export DOTFILES_THEME

if (( $+commands[lua] )); then
  typeset theme_exports
  theme_exports="$(
    lua - "$DOTFILES_THEME" "${_dotfiles_theme_files[@]}" <<'EOF'
local active_theme = arg[1]
local theme_files = {}
for i = 2, #arg do
  table.insert(theme_files, arg[i])
end

local defaults = {
  prompt_ok = "76",
  prompt_error = "196",
  dir = "31",
  dir_shortened = "103",
  dir_anchor = "39",
  vcs_meta = "244",
  vcs_clean = "76",
  vcs_modified = "178",
  vcs_untracked = "39",
  vcs_conflicted = "196",
  vcs_icon = "76",
  vcs_loading = "244",
  status_ok = "70",
  status_error = "160",
  command_time = "101",
  background_jobs = "70",
  direnv = "178",
  asdf = "66",
}

local themes
for _, path in ipairs(theme_files) do
  local ok, loaded_themes = pcall(dofile, path)
  if ok and type(loaded_themes) == "table" then
    themes = loaded_themes
    break
  end
end

local prompt = {}
if themes then
  local selected_theme = themes[active_theme] or themes.coolnight
  if selected_theme and type(selected_theme.prompt) == "table" then
    for key, value in pairs(selected_theme.prompt) do
      prompt[key] = tostring(value)
    end
  end
end

local ordered_keys = {
  "prompt_ok",
  "prompt_error",
  "dir",
  "dir_shortened",
  "dir_anchor",
  "vcs_meta",
  "vcs_clean",
  "vcs_modified",
  "vcs_untracked",
  "vcs_conflicted",
  "vcs_icon",
  "vcs_loading",
  "status_ok",
  "status_error",
  "command_time",
  "background_jobs",
  "direnv",
  "asdf",
}

for _, key in ipairs(ordered_keys) do
  local value = prompt[key] or defaults[key]
  print(string.format("typeset -gx DOTFILES_P10K_%s=%q", string.upper(key), value))
end
EOF
  )"

  [[ -n "$theme_exports" ]] && eval "$theme_exports"
fi
