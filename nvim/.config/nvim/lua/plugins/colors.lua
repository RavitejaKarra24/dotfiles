local function load_wezterm_themes()
  local theme_files = {
    vim.fn.expand("~/.config/wezterm/themes.lua"),
    vim.fn.expand("~/.dotfiles/wezterm/.config/wezterm/themes.lua"),
  }

  for _, theme_file in ipairs(theme_files) do
    if vim.fn.filereadable(theme_file) == 1 then
      local ok, themes = pcall(dofile, theme_file)
      if ok and type(themes) == "table" then
        return themes
      end
    end
  end

  return {}
end

-- Matches WezTerm active_theme = "deep_ocean" → onedark
local DEFAULT_COLORSCHEME = "onedark"

local function resolve_colorscheme()
  local terminal_theme = vim.env.DOTFILES_THEME
  if terminal_theme and terminal_theme ~= "" then
    local selected_theme = load_wezterm_themes()[terminal_theme]
    if selected_theme and selected_theme.nvim then
      return selected_theme.nvim
    end
  end

  return DEFAULT_COLORSCHEME
end

local function make_background_transparent()
  local transparent_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "EndOfBuffer",
    "NonText",
    "SignColumn",
    "FoldColumn",
    "LineNr",
    "CursorLineNr",
    "WinSeparator",
  }

  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

local function apply_colorscheme()
  local colorscheme = resolve_colorscheme()
  local ok = pcall(vim.cmd.colorscheme, colorscheme)

  if not ok then
    pcall(vim.cmd.colorscheme, DEFAULT_COLORSCHEME)
  end

  make_background_transparent()
end

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    dependencies = {
      "folke/tokyonight.nvim",
      { "catppuccin/nvim", name = "catppuccin" },
      "ellisonleao/gruvbox.nvim",
      "shaunsingh/nord.nvim",
      "navarasu/onedark.nvim",
    },
    config = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = make_background_transparent,
      })

      apply_colorscheme()
    end,
  },
}

