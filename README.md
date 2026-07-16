# Dotfiles

macOS developer environment managed with [GNU Stow](https://www.gnu.org/software/stow/) and a `Brewfile`.

## Quick start

```bash
git clone git@github.com:RavitejaKarra24/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install.sh
```

Safe to re-run: `~/.dotfiles/install.sh`

## Layout

| Package | Purpose |
|---------|---------|
| `aerospace/` | AeroSpace tiling window manager |
| `zsh/` | Shell config (Oh My Zsh, Atuin, fzf, zoxide) |
| `nvim/` | Neovim (Lazy, LSP, FFF, oil, gitsigns, …) |
| `ghostty/` | Ghostty terminal |
| `wezterm/` | WezTerm terminal |
| `tmux/` | Terminal multiplexer |
| `karabiner/` | Caps Lock → Meh / Escape |
| `sketchybar/` | macOS status bar |
| `lazygit/` | Git TUI + delta |
| `git/` | Global gitconfig (delta, aliases) |
| `yazi/` | File manager TUI |
| `btop/` | System monitor |
| `Brewfile` | All Homebrew packages/casks |
| `install.sh` | Bootstrap: brew, stow, services |

Neovim keybindings: see [`nvim/.config/nvim/README.md`](nvim/.config/nvim/README.md).

## Window management (AeroSpace)

**yabai + skhd were removed.** Window management is **AeroSpace** only.

- Config: `aerospace/.aerospace.toml`
- Caps Lock (via Karabiner) = **Meh** (`cmd + ctrl + alt`); alone = Escape
- **Meh + hjkl** → focus window
- **Meh + Shift + hjkl** → move window
- **Alt + 1–9 / B E M N P T V** → workspaces
- **Alt + Shift + …** → move window to workspace
- SketchyBar starts with AeroSpace; workspace changes trigger bar updates

Installer stows `aerospace` and starts sketchybar (AeroSpace uses start-at-login).

## Packages (Brewfile highlights)

| Added / primary | Removed / replaced |
|-----------------|--------------------|
| AeroSpace (tiling WM) | yabai, skhd |
| `fastfetch` | `neofetch` |
| `git-delta` | — |
| `ctop` | — |

## Git + lazygit

- Credential helper: **osxkeychain**
- Pager/editor: **delta** / **nvim**
- Pull rebase, push auto-setup-remote, zdiff3 conflicts
- Aliases: `st`, `co`, `br`, `ci`, `lg`, `undo`, `amend`, …
- Lazygit: nerd fonts, deep-ocean theme, delta pager, `P` = create PR, `p` = push `-u`

## Shell (zsh)

- **Lazy NVM** — loads only on first `nvm` / `node` / `npm` / `npx`
- Single fzf init; larger history (5000) with Atuin primary
- Conditional Anaconda PATH
- `EDITOR` / `VISUAL` = nvim
- Aliases: `n` (nvim), `lg` (lazygit), `bt` (btop), `gq` (ghq + fzf)
- PATH for Grok, Antigravity, local npm, Homebrew

## Neovim (summary of recent plugin work)

| Change | Detail |
|--------|--------|
| Colorscheme | Default **onedark** (deep_ocean / WezTerm-aligned); was rose-pine |
| oil.nvim | File explorer; `<leader>pv` and `-` |
| gitsigns | Hunk nav/stage/reset/blame (`]h` `[h` `<leader>h*`) |
| lazygit.nvim | `<leader>gg` / `gf` / `gl` |
| which-key | Leader group hints |
| Conform | rustfmt, gofmt, ruff/black, stylua; `<leader>f` prefers Conform |
| Treesitter | More langs + indent; playground removed |
| Format | `<leader>f` → Conform with LSP fallback |

Full map: [`nvim/.config/nvim/README.md`](nvim/.config/nvim/README.md).

## Terminal & tools

- **Ghostty**: deep_ocean palette (was coolnight)
- **btop**: v1.4.7 options (GPU graphs, presets, mouse, etc.)
- **Karabiner**: Caps hold = Meh; alone = Escape (for AeroSpace)

## Changelog (since last commit)

Working-tree changes documented in this README and the nvim README:

1. **WM migration** — delete yabai/skhd configs; add AeroSpace; update `install.sh` + Brewfile
2. **Git ergonomics** — delta, aliases, keychain, lazygit theme/commands
3. **Neovim plugins** — oil, gitsigns, lazygit, which-key; onedark default; broader formatters/parsers
4. **Shell polish** — lazy NVM, aliases, cleaner PATH/history
5. **Theme alignment** — Ghostty deep_ocean; lazygit colors match
6. **Brewfile** — fastfetch, git-delta, ctop; drop yabai/skhd/neofetch
7. **Karabiner** — Caps → Meh + Escape alone
