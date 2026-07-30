# pi

Global [pi](https://github.com/earendil-works/pi) coding-agent config (my-pi-setup style).

Stow target: `~/.pi/agent/`

## What this provides

### Extensions
- ask-user, background-terminals, copy-all, file-search (`fd`/`rg`), firecrawl-search
- git-info, model-info, subagents, ui-customization, workflows, shared helpers

### Skills (pi-local, under `skills/`)
- **Core (my-pi-setup):** `background-terminals`, `subagents`
- **pi-skills:** brave-search, browser-tools, gccli, gdcli, gmcli, transcribe, vscode, youtube-transcript
- **Android / Kotlin / mobile:** adaptive, android-*, appfunctions, camerax, compose-*, kotlin-*, navigation-3, play-*, r8-analyzer, styles, verified-email, …

### Shared skills
Cross-agent skills live in the **`agents`** package (`~/.agents/skills/`).  
`install.sh` links them into `~/.pi/agent/skills/` so pi sees them too.

### Other
- Theme: `github-dark-default` (pi-spark dark theme filtered out)
- Package: `npm:pi-spark` (extension polish)
- `AGENTS.md`, `package.json` deps (`effect`, firecrawl, etc.), `SETUP.md`

## Fresh machine

`./install.sh` stows `agents` + `pi`, installs
`@earendil-works/pi-coding-agent` if needed, runs `npm ci` in the unified
workspace, links shared skills, and installs only allowlisted skill
dependencies from lockfiles.

Manual:

```bash
stow -d ~/.dotfiles -t ~ --no-folding agents
stow -d ~/.dotfiles -t ~ --no-folding pi
npm install -g @earendil-works/pi-coding-agent
# Install next to the *real* package.json (stow target). Extensions resolve
# modules from that path, not from ~/.pi/agent/node_modules alone.
cd "$(dirname "$(realpath ~/.pi/agent/package.json)")" && npm ci
# link shared skills into pi (or re-run install.sh setup)
for s in ~/.agents/skills/*; do
  name=$(basename "$s")
  dest=~/.pi/agent/skills/"$name"
  [ -e "$dest" ] || ln -s "../../../.agents/skills/$name" "$dest"
done
# optional reviewed skill package deps
cd ~/.pi/agent/skills/pi-skills/brave-search
npm ci --ignore-scripts --no-fund --no-audit
cp ~/.pi/agent/.env.example ~/.pi/agent/.env   # set FIRECRAWL_API_KEY if desired
```

## Not tracked (machine-local)

- `auth.json`, `.env`, `sessions/`, `models-store.json`, `node_modules/`, `bin/`
- Skill `node_modules` (reinstalled by `install.sh`)
- `settings.json` — pi rewrites `lastChangelogVersion` on upgrade and reformats
  the file, so the live copy is machine-local. The durable settings (default
  model and provider, thinking level, theme, and the curated skill allow/deny
  list) live in `seeds/pi/settings.json`, which `install.sh` copies into place
  on a machine that has no settings yet. Edit the seed by hand to carry a
  change to another Mac.

## Firecrawl

Optional. Put `FIRECRAWL_API_KEY=fc-...` in `~/.pi/agent/.env`.
