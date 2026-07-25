---
name: skill-router
description: Select the most relevant installed Codex skills on demand without injecting the full skill catalog into every thread. Use when routing a task to specialist skills.
---

# Dynamic Skill Router

Codex is configured with `skills.include_instructions = false`. Installed skills remain enabled and explicitly invokable, but their metadata is not added to every thread.

## Route a task

Run the bundled selector with the user's request and any detected project stack:

```bash
python3 ~/.codex/skills/skill-router/scripts/select_skills.py \
  --cwd "$PWD" \
  "<task and project stack>"
```

The selector searches:

- project `.agents/skills` directories from the working directory to the repository root
- `~/.codex/skills`
- `~/.agents/skills`
- installed plugin skill caches

It deduplicates symlinked skills and ranks frontmatter names and descriptions without loading every `SKILL.md` into model context.

## Apply matches

1. Read the complete `SKILL.md` for only the best 1–3 genuinely relevant matches.
2. Follow relative references from each selected skill's directory.
3. Ignore weak or incidental matches.
4. If no match applies, proceed without a skill.
5. For multi-domain tasks, use focused subqueries rather than loading the full catalog.

Use `--limit N` to change the result count or `--all` only for explicit catalog-management requests.
