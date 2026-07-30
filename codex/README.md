# Codex

Portable Codex configuration managed with GNU Stow.

Stow target: `~/.codex/`

## Tracked

- `AGENTS.md` — global instructions
- `keybindings.json` — desktop keybindings
- `rules/default.rules` — command approval rules
- `skills/skill-router/` — the small on-demand router required by `AGENTS.md`

Everything else under `~/.codex/` is authentication, generated data, cached content, or runtime state and stays machine-local. Shared skills remain in the separate `agents/` Stow package.

## `config.toml` is machine-local

Codex rewrites `config.toml` continuously: a `[projects.*]` trust entry per directory it opens, `last_updated` marketplace timestamps, `[plugins.*]` state, `[tui.model_availability_nux]` counters, and an `[mcp_servers.node_repl]` block carrying absolute paths into `ChatGPT.app` plus the app version and browser client hashes. Almost none of that is portable, and all of it dirtied the repository on every session.

The live file is therefore gitignored. The durable settings — model, reasoning effort, approvals reviewer, `[features]`, `[desktop]`, and the skill-routing block — are tracked in `seeds/codex/config.toml`, which `install.sh` copies into place on a machine that has no config yet. An existing file is never overwritten. Edit the seed by hand to carry a change to another Mac.

## Fresh machine

The main installer stows this package. To install it manually:

```bash
stow -d ~/.dotfiles -t ~ --no-folding codex
```

The resulting config and skill-router files are symlinks into this repository. Editing them through `~/.codex/` therefore edits the tracked source directly.

`auth.json`, sessions, history, caches, databases, logs, and generated plugin state are intentionally not tracked. Sign in to Codex separately on each machine.
