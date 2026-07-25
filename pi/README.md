# pi

Global [pi](https://github.com/earendil-works/pi) coding-agent config (my-pi-setup style).

Stow target: `~/.pi/agent/`

## What this provides

- Extensions: ask-user, background-terminals, copy-all, file-search (`fd`/`rg`), firecrawl-search, git-info, model-info, subagents, ui-customization, workflows
- Theme: `github-dark-default` (from my-pi-setup; pi-spark dark theme filtered out)
- Package: `npm:pi-spark` (extension polish; light theme still available)
- Skills: `background-terminals`, `subagents`
- `AGENTS.md`, `package.json` deps (`effect`, firecrawl, etc.)

## Fresh machine

`./install.sh` stows this package, installs `@earendil-works/pi-coding-agent` if needed, then runs `npm install` in `~/.pi/agent`.

Manual:

```bash
stow -d ~/.dotfiles -t ~ --no-folding pi
npm install -g @earendil-works/pi-coding-agent
cd ~/.pi/agent && npm install
cp ~/.pi/agent/.env.example ~/.pi/agent/.env   # set FIRECRAWL_API_KEY if desired
```

## Not tracked (machine-local)

- `auth.json`, `.env`, `sessions/`, `models-store.json`, `node_modules/`, `bin/`
- Extra skills under `~/.pi/agent/skills` or `~/.agents/skills` (install separately)

## Firecrawl

Optional. Put `FIRECRAWL_API_KEY=fc-...` in `~/.pi/agent/.env`.
