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

`./install.sh` stows `agents` + `pi`, installs `@earendil-works/pi-coding-agent` if needed, runs `npm install` in `~/.pi/agent`, links shared skills, and installs skill npm deps.

Manual:

```bash
stow -d ~/.dotfiles -t ~ --no-folding agents
stow -d ~/.dotfiles -t ~ --no-folding pi
npm install -g @earendil-works/pi-coding-agent
cd ~/.pi/agent && npm install
# link shared skills into pi (or re-run install.sh setup)
for s in ~/.agents/skills/*; do
  name=$(basename "$s")
  dest=~/.pi/agent/skills/"$name"
  [ -e "$dest" ] || ln -s "../../../.agents/skills/$name" "$dest"
done
# optional skill package deps
find ~/.pi/agent/skills -name package.json ! -path '*/node_modules/*' -execdir npm install --no-fund --no-audit \;
cp ~/.pi/agent/.env.example ~/.pi/agent/.env   # set FIRECRAWL_API_KEY if desired
```

## Not tracked (machine-local)

- `auth.json`, `.env`, `sessions/`, `models-store.json`, `node_modules/`, `bin/`
- Skill `node_modules` (reinstalled by `install.sh`)

## Firecrawl

Optional. Put `FIRECRAWL_API_KEY=fc-...` in `~/.pi/agent/.env`.
