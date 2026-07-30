# Dotfiles

macOS developer environment managed with [GNU Stow](https://www.gnu.org/software/stow/) and a `Brewfile`.

## Quick start

```bash
git clone git@github.com:RavitejaKarra24/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install.sh
```

Without an SSH key, use:

```bash
git clone https://github.com/RavitejaKarra24/dotfiles.git ~/.dotfiles
```

Preview first with `./install.sh --dry-run`. The installer is safe to re-run,
backs up real conflicts with a manifest, and refuses to replace unrelated
symlinks. Use `--non-interactive` to skip opt-in macOS preferences.

## Update installed packages

Run the global updater to refresh Homebrew formulae/casks, language runtimes,
global CLI packages, Mac App Store apps (when `mas` is installed), and
VS Code/Cursor extensions:

```bash
cd ~/.dotfiles
./update.sh
```

Preview the detected update tasks without changing anything:

```bash
./update.sh --dry-run
```

Project-local dependencies are intentionally not included. Update those inside
each project so dependency changes, lockfiles, and tests stay together.

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
| `pi/` | pi coding agent global config (`~/.pi/agent`) — extensions, themes, pi-local skills |
| `codex/` | Codex config (`~/.codex`) — settings, instructions, keybindings, rules, skill router |
| `agents/` | Shared agent skills (`~/.agents/skills`) used by pi, Claude, Codex, Grok, … |
| `seeds/` | Durable settings for the app-rewritten config files (see below) |
| `Brewfile` | All Homebrew packages/casks |
| `install.sh` | Safe bootstrap: preflight, Brew, Stow, dependencies |
| `update.sh` | Update global packages, runtimes, apps, and editor extensions |
| `doctor.sh` | Repository-wide config, Stow, security, and Pi validation |
| `uninstall.sh` / `restore.sh` | Remove managed links and restore conflict backups |

Neovim keybindings: see [`nvim/.config/nvim/README.md`](nvim/.config/nvim/README.md).

### App-rewritten settings (`seeds/`)

Codex, Zed, and pi rewrite their own settings files whenever a model is switched, a plugin refreshes, or a directory is trusted. Because those files are Stow symlinks into this repository, every such change dirtied the working tree with values that are timestamps, absolute paths into app bundles, or client hashes.

Three files are therefore gitignored and stay machine-local:

| Live file (gitignored) | Tracked seed | Why it churns |
|---|---|---|
| `codex/.codex/config.toml` | `seeds/codex/config.toml` | Project trust entries, marketplace timestamps, plugin state, app version, browser client hashes |
| `zed/.config/zed/settings.json` | `seeds/zed/settings.json` | `agent.default_model` rewritten on every model switch |
| `pi/.pi/agent/settings.json` | `seeds/pi/settings.json` | `lastChangelogVersion` rewritten on upgrade |

The seeds hold the settings worth carrying to another Mac. `install.sh` copies a seed into place only when the live file is missing, so an existing machine's state is never overwritten. To carry a deliberate change to another Mac, edit the seed by hand — changing the setting in the app alone no longer reaches the repository, which is the point.

## Window management (AeroSpace)

**yabai + skhd were removed.** Window management is **AeroSpace** only.

- Config: `aerospace/.aerospace.toml`
- Caps Lock (via Karabiner) = **Meh** (`cmd + ctrl + alt`); alone = Escape
- **Meh + hjkl** → focus window
- **Meh + Shift + hjkl** → move window
- **Alt + 1–9 / B E M N P T V** → workspaces
- **Alt + Shift + …** → move window to workspace
- SketchyBar starts with AeroSpace; workspace changes trigger bar updates

Installer stows `aerospace`; AeroSpace is the single owner of SketchyBar
startup.

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
| Conform | rustfmt, gofmt, ruff, stylua; `<leader>f` prefers Conform |
| Treesitter | More langs + indent; playground removed |
| Format | `<leader>f` → Conform with LSP fallback |

Full map: [`nvim/.config/nvim/README.md`](nvim/.config/nvim/README.md).

## Terminal & tools

- **Ghostty**: deep_ocean palette (was coolnight)
- **btop**: v1.4.7 options (GPU graphs, presets, mouse, etc.)
- **Karabiner**: Caps hold = Meh; alone = Escape (for AeroSpace)

## pi coding agent

Stow package `pi/` → `~/.pi/agent` (extensions, theme, settings, package deps).

- Installer runs `npm install -g @earendil-works/pi-coding-agent` if needed, then `npm ci` in the unified workspace
- Theme: `github-dark-default`; package `npm:pi-spark` with its dark theme filtered to avoid collisions
- Secrets stay local: `auth.json`, `.env`, `sessions/`, `models-store.json` (not in git)
- Optional Firecrawl: `FIRECRAWL_API_KEY` in `~/.pi/agent/.env`

Details: [`pi/README.md`](pi/README.md).

## Codex

Stow package `codex/` links only durable configuration into the existing `~/.codex/` directory. Authentication, sessions, history, caches, generated files, and other runtime state remain machine-local.

Because the live files are Stow symlinks, edits made through `~/.codex/config.toml` (or the other tracked config paths) update this repository directly.

Details: [`codex/README.md`](codex/README.md).

## Validation

Run the complete local audit before committing:

```bash
./doctor.sh
```

Use `./doctor.sh --quick` for config syntax, application-aware Yazi validation,
and a disposable Stow plan without the Pi test suite. This personal repository
is intentionally macOS-only and uses local validation rather than hosted CI.
