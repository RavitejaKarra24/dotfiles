# agents

Shared agent skills at `~/.agents/skills/`.

Used by pi (via symlinks under `~/.pi/agent/skills/`), Claude Code, Codex, Grok, and other tools that read the agents skills directory.

## Fresh machine

Stowed by `./install.sh` (package `agents`). Manual:

```bash
stow -d ~/.dotfiles -t ~ --no-folding agents
```

Pi setup then links these into `~/.pi/agent/skills/` (see `install.sh` `link_pi_shared_skills`).

## Not tracked

- Runtime/cache under `~/.agents/` other than skills + skill-lock
- `node_modules` inside any skill
