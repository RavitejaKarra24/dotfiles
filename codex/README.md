# Codex

Portable Codex configuration managed with GNU Stow.

Stow target: `~/.codex/`

## Tracked

- `config.toml` — Codex CLI/app settings
- `AGENTS.md` — global instructions
- `keybindings.json` — desktop keybindings
- `rules/default.rules` — command approval rules
- `skills/skill-router/` — the small on-demand router required by `AGENTS.md`

Everything else under `~/.codex/` is authentication, generated data, cached content, or runtime state and stays machine-local. Shared skills remain in the separate `agents/` Stow package.

## Fresh machine

The main installer stows this package. To install it manually:

```bash
stow -d ~/.dotfiles -t ~ --no-folding codex
```

The resulting config and skill-router files are symlinks into this repository. Editing them through `~/.codex/` therefore edits the tracked source directly.

`auth.json`, sessions, history, caches, databases, logs, and generated plugin state are intentionally not tracked. Sign in to Codex separately on each machine.
