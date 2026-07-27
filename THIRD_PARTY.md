# Third-party configuration and assets

This repository contains authored configuration alongside pinned or vendored
third-party material. Review this file and the referenced lockfiles whenever
updating vendored content.

| Content | Source / revision record | License record | Update mechanism |
|---|---|---|---|
| Yazi Catppuccin Mocha flavor | `yazi/.config/yazi/package.toml` | Files under `flavors/catppuccin-mocha.yazi/` | `ya pkg upgrade` |
| Shared agent skills | `agents/.agents/.skill-lock.json` | Per-skill files and upstream metadata | Skill installer plus integrity review |
| Pi-local skills | `pi/.pi/agent/skills/` package metadata | Per-skill files and upstream metadata | Explicit reviewed updates only |
| Codex skill router | `codex/.codex/skills/skill-router/` | Package-local metadata | Controlled Codex update |
| Ghostty shader collection | Headers in `ghostty/.config/ghostty/shaders/` | Incomplete; verify upstream source/license before redistribution | Manual review only |

Generated dependency trees, runtime databases, auth state, logs, and compiled
binaries are intentionally excluded by Git and Stow. The SketchyBar helper
source remains tracked, while its architecture-specific compiled output does
not.
