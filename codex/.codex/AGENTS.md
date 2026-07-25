# Global Codex instructions

## Dynamic skill routing

The startup skill catalog is intentionally hidden to avoid spending context on every installed skill.

Before substantive work, unless the user explicitly invoked a skill:

1. Run `python3 ~/.codex/skills/skill-router/scripts/select_skills.py --cwd "$PWD" "<user request plus the detected project stack>"`.
2. Read the complete `SKILL.md` for the best 1–3 genuinely relevant matches before editing or planning.
3. Do not load loosely related skills merely because they were returned. If no result is relevant, continue without a skill.
4. For a multi-domain task, rerun the router with focused subqueries instead of loading the entire catalog.

Explicit `$skill-name` mentions still take precedence. Never read the full skill catalog into context.
