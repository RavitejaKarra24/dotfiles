# Dotfiles audit and improvement roadmap

Audited on 2026-07-26. This is a point-in-time review of the tracked
configuration, bootstrap/update scripts, active tool versions, ignored runtime
state, and the repository's local test/validation results.

No existing configuration file was intentionally edited as part of this audit.

## Execution status: `efficiency_experiment`

The high-confidence roadmap items were implemented on the
`efficiency_experiment` branch after this audit. The branch now includes:

- removal of the blanket Codex `curl` approval and unsafe shell interpolation;
- guarded shell startup, secret-history filtering, and mode-0600 secret setup;
- safe Stow exclusions, conflict manifests, dry-run bootstrap, restore, and
  uninstall workflows;
- a Yazi 26.5.6 minimal configuration and refreshed pinned flavor;
- active AeroSpace/SketchyBar integration with corrected CPU/network metrics;
- a tracked Neovim lockfile, declarative Mason tools, secure temp runners, and
  one Python formatter;
- a unified Pi npm workspace with exact Pi/Effect beta pins, one lockfile,
  deterministic default tests, and explicitly gated live integration tests;
- a local macOS-only `doctor.sh`, repository hygiene files, dependency
  declarations, and third-party provenance guidance.

Suggestions that are preference or policy decisions remain intentionally
unforced: choosing only one terminal, removing one runtime manager, changing
personal Codex trust entries, splitting public/private identity, deleting all
inactive UI examples, commit signing, and generating every application theme
from one palette. Those choices need the owner’s desired workflow rather than
an automated guess.

The post-migration online npm audit reports no high/critical findings. It does
report seven moderate findings inherited through `@hono/node-server` (a
Windows encoded-backslash path traversal in static serving), with no upstream
fix currently available. The configured environment is macOS and does not
expose that Windows path behavior; retain this note for future dependency
updates.

## Priority guide

- **P0 — fix first:** confirmed security risk, data-loss risk, or broken config.
- **P1 — next:** material reliability, reproducibility, or maintainability issue.
- **P2 — improve:** worthwhile cleanup, performance, portability, or ergonomics.
- **P3 — optional:** polish and personal-preference improvements.

## Executive summary

The repository has a strong foundation: it uses Stow, separates most secrets
and runtime state, has a readable top-level README, keeps package intent in a
Brewfile, and already has meaningful tests for the custom pi extensions.

The highest-value work is:

1. **[P0] Remove the blanket Codex `curl` approval.**
   `codex/.codex/rules/default.rules` allows every command matching `curl`.
   This bypasses approval for arbitrary downloads, uploads, and possible secret
   exfiltration. Delete the rule or replace it with narrowly scoped rules for
   exact hosts and safe flags.

2. **[P0] Rebuild the Yazi config from the installed version's defaults.**
   Yazi 26.5.6 currently refuses the managed config. It first rejects
   `"$schema"` in `yazi.toml` and `keymap.toml`; after temporarily removing
   those declarations, it rejects old `name`-based open rules; after adapting
   those, it rejects the old fetcher shape because `group` is missing. This is
   version drift across the copied default config, not a one-line problem.

3. **[P0] Fix command injection in `dict()`.**
   `zsh/.zshrc:261-274` inserts `$word` directly into Python source inside
   single quotes. A word containing a quote can change the Python program.
   Pass the word through `sys.argv` or stdin instead. URL-encode the online
   lookup and use `curl --fail --show-error --max-time`.

4. **[P0] Make Stow ignore dependency and runtime trees.**
   `.gitignore` does not affect GNU Stow. With the current ignored dependencies
   present, a dry run of the `pi` package proposed roughly **15,490 links and
   588 directories**, largely from `node_modules`. Add a root
   `.stow-local-ignore` and/or explicit `--ignore` rules for `node_modules`,
   caches, sessions, logs, `.DS_Store`, generated binaries, and other runtime
   state.

5. **[P0] Harden secret creation and loading.**
   `install.sh` creates `~/.zshrc.secrets` without enforcing permissions.
   Create it under `umask 077` or with mode `0600`. Prefer macOS Keychain,
   1Password CLI, or per-project `direnv` loading over exporting every API key
   into every shell and every child process.

6. **[P0] Do not delete unrelated symlinks during conflict recovery.**
   In `install.sh:226-239`, any symlink at a target path can be removed after a
   Stow failure, even when it does not belong to this repository. Resolve all
   conflicts first, back up links as links, and only replace a link after
   verifying that it points into this dotfiles checkout.

7. **[P1] Repair the pi dependency graph and make its checks green.**
   `npm run check` currently fails from version skew: direct
   `@earendil-works/pi-tui` is 0.80.6 while the coding agent brings 0.80.10;
   root Effect packages resolve to beta.101 while several extension trees use
   beta.98. Consolidate the extensions into npm workspaces, use one dependency
   graph, and pin beta packages exactly.

8. **[P1] Make the AeroSpace/SketchyBar implementation match the README.**
   `sketchybarrc` sources only quotes, calendar, network, CPU, and battery.
   It does not source `items/aerospace.sh`, so the documented workspace
   indicators are not created. The calendar still invokes `zen.sh`, which
   manipulates many items that are no longer active.

9. **[P1] Track Neovim's lockfile.**
   `nvim/.config/nvim/lazy-lock.json` is deliberately ignored. That makes a
   fresh install fetch a different plugin graph over time. Commit it and update
   it deliberately.

10. **[P1] Add one repository-wide local validation command.**
    The repo had no common audit target. A dotfiles repository should make it
    easy to check locally that configs parse, dependencies align, secrets are
    absent, and a fresh Stow plan is safe.

## Security and privacy

- **[P0] Narrow Codex command permissions.** Avoid executable-wide approvals
  such as `curl`, `bash`, `sh`, `python`, `node`, `git`, or package managers.
  Scope rules to an exact command shape and keep uploads, credentials, pipes,
  output paths, and shell execution approval-gated.

- **[P0] Remove shell-to-language interpolation.** Besides fixing `dict()`,
  adopt the rule that shell values enter Python, Ruby, Node, `osascript`, `jq`,
  and SQL only through arguments/stdin—not by constructing source code.

- **[P1] Pin or verify remote bootstrap code.** `install.sh` executes remote
  Homebrew, Oh My Zsh, rustup, NVM, and Bun installers. Prefer release-pinned
  URLs plus checksums/signatures. When an upstream only supports a live
  installer, download it, inspect/verify it, then execute it as a separate
  step.

- **[P1] Treat third-party skills as executable dependencies.** The shared
  skills contain scripts and instructions that agents may execute.
  `install_pi_skill_deps` also runs `npm install` across discovered packages.
  Use an allowlist, verify the hashes in `.skill-lock.json`, review updates,
  and avoid lifecycle scripts by default unless a package explicitly needs
  them.

- **[P1] Add automated secret scanning.** Run a scanner such as Gitleaks from
  the local doctor, with an optional history scan before publishing changes.
  The audit found no obvious live token/private-key pattern in authored current
  config; two history matches were in vendored UI data and appear to be false
  positives. Automated scans should exclude known fixtures narrowly, not whole
  directories.

- **[P1] Make history protection explicit.** Set Atuin's `secrets_filter =
  true` explicitly, add filters for commands containing authorization headers,
  token flags, and `export *_KEY=...`, and enable Zsh `hist_ignore_space`.
  Decide explicitly whether Atuin history should sync.

- **[P1] Reduce trust scope in Codex.** `codex/.codex/config.toml` trusts many
  absolute project paths, including an entire experiments parent directory.
  Trust only active repositories that genuinely need it. A trusted parent can
  silently broaden the scope to future children.

- **[P2] Separate public and private machine metadata.** The public repo exposes
  a personal email, project names, directory layout, installed tools, trusted
  project paths, and app preferences. Keep shareable defaults tracked and put
  private identity/trust/path overlays in an ignored local include or generated
  local file.

- **[P2] Add third-party provenance and licenses.** The repository vendors
  skills, schemas, a Yazi flavor, a compiled helper, and 35 Ghostty shaders.
  Record source URL, revision, license, and local modifications in a NOTICE or
  manifest. Several shader files do not show provenance in their headers.

## Bootstrap, Stow, and recovery

- **[P0] Add `.stow-local-ignore`.** At minimum exclude:
  `node_modules`, `.git`, `.DS_Store`, logs, caches, sessions, auth files,
  environment files, generated binaries, package-manager stores, and editor
  state. Test the ignore rules with a populated working copy, not only a clean
  clone.

- **[P1] Derive the repository path from the script.**
  `DOTFILES_DIR="$HOME/.dotfiles"` makes the script fail or target the wrong
  checkout when cloned elsewhere. Resolve the directory containing
  `install.sh`.

- **[P1] Add strict, informative error handling.** Use `set -Eeuo pipefail`,
  an `ERR` trap that prints the failed step and line, and explicit exceptions
  for commands whose failure is intentionally tolerated.

- **[P1] Add an install preflight.** Confirm macOS, architecture, network
  availability, writable targets, free disk space, required shell version,
  and the intended repository path before making changes.

- **[P1] Make Homebrew discovery architecture-neutral.** Do not assume
  `/opt/homebrew`. Use an existing `brew`, or check the Apple Silicon and Intel
  prefixes, then evaluate `brew shellenv`.

- **[P1] Make conflict handling transactional.** First produce a complete plan;
  abort on unresolved targets; copy conflicts to a timestamped backup; write a
  manifest of old path, backup path, type, and checksum; only then apply Stow.

- **[P1] Add restore and uninstall commands.** A great bootstrap has a tested
  inverse: unstow packages, restore the exact backup manifest, stop only the
  services it started, and leave package removal opt-in.

- **[P1] Add `--dry-run`, `--non-interactive`, and package selection.**
  Profiles such as `core`, `terminal`, `desktop`, `agents`, and `all` make
  fresh-machine setup faster and safer.

- **[P1] Use `npm ci` for locked installs.** A tracked `package-lock.json`
  should produce a clean dependency tree. Do not reuse stale `node_modules`;
  detect mismatch and offer a clean, reproducible reinstall.

- **[P1] Wait correctly for Xcode tools.** The current script asks the user to
  press a key after launching the installer. Poll `xcode-select -p`, or stop
  with a clear “rerun after installation” message.

- **[P1] Secure the macOS defaults workflow.** Record current values before
  writing them, support a dry run, keep defaults in a declarative data file,
  and generate an undo script. Some preferences are personal and should be a
  separate opt-in profile.

- **[P2] Resolve duplicate service ownership.** AeroSpace starts SketchyBar in
  `after-startup-command`, while `install.sh` can also start it with
  `brew services`. Pick one owner to avoid duplicate launches and confusing
  restart behavior.

- **[P2] Remove or call dead installer code.** `create_github_repo()` is defined
  but never invoked, and section numbering repeats. Since publishing is not a
  normal bootstrap responsibility, removing it is cleaner than enabling it.

- **[P2] Avoid creating empty backup directories.** Create a backup directory
  only when at least one conflict is actually saved.

- **[P2] Add a post-install doctor.** Verify symlink targets, required commands,
  shell startup, Neovim headless startup, Yazi parsing, AeroSpace/SketchyBar
  integration, secrets permissions, and expected services.

## Shell configuration

- **[P0] Fix Fish startup.** `fish/.config/fish/conf.d/atuin.env.fish` sources
  `~/.atuin/bin/env.fish`, which does not exist on this Homebrew-based machine.
  Guard it or initialize the Homebrew binary with `atuin init fish | source`.

- **[P1] Keep `.zshenv` minimal and failure-free.** It runs for non-interactive
  shells too, yet unconditionally sources `~/.cargo/env`. Guard the file and
  keep interactive setup out of `.zshenv`.

- **[P1] Set XDG variables before dependent tools run.**
  `XDG_CONFIG_HOME` is set near the end of `.zshrc`. Establish XDG variables
  once, early, ideally in a small environment file shared by shells.

- **[P1] Normalize and deduplicate `PATH`.** Use Zsh's `path` array with
  `typeset -U path PATH`, add only existing directories, and avoid a mix of
  appending and prepending. Current config contains Intel Homebrew paths,
  Apple Silicon paths, hard-coded user paths, two Antigravity locations,
  repeated Solana setup, and legacy AdoptOpenJDK/OpenJDK entries.

- **[P1] Choose one manager per runtime.** The system currently mixes Homebrew
  Node with NVM, Homebrew Ruby with rbenv, and multiple Java paths. Document
  which manager owns Node, Ruby, Python, Java, Rust, and Go; install and update
  each runtime through that one owner.

- **[P1] Choose one source for Zsh plugins.** Autosuggestions and syntax
  highlighting are installed as Homebrew formulae and cloned into Oh My Zsh.
  Keep one method so versioning and updates are unambiguous.

- **[P1] Initialize completion once.** Oh My Zsh initializes completion, then
  `.zshrc` calls `compinit -C` again for Grok. Add Grok's completion directory
  to `fpath` before the main initialization and keep one audited compinit/cache.

- **[P1] Resolve the Powerlevel10k contradiction.** The instant-prompt cache is
  sourced at the top, then `POWERLEVEL9K_INSTANT_PROMPT=off` is set afterward.
  Either enable it correctly or remove the bootstrap block.

- **[P1] Guard optional commands.** `zoxide`, `atuin`, `rbenv`, and several app
  integrations are invoked unconditionally. A missing optional package should
  degrade gracefully instead of making shell startup noisy or broken.

- **[P1] Remove hard-coded personal installer paths.** Google Cloud SDK is
  sourced from `~/Downloads`, while LM Studio and Antigravity use absolute
  `/Users/ravitejakarra/...` paths. Use `$HOME`, stable install locations, and
  existence checks; preferably install/configure them declaratively.

- **[P1] Fix missing command dependencies.** The Pomodoro aliases require
  `terminal-notifier`, which is not installed. Tmux and Neovim call a manually
  installed `/usr/local/bin/sessionizer`, which is not in the Brewfile or
  installer. Install these dependencies or make the features conditional.

- **[P2] Make helper functions cancellation-safe.** `gq` can run `cd ""` when
  fzf is cancelled. Return without changing directory on an empty selection.
  The `y()` function should use a trap/always block so its temp file is removed
  even when Yazi or `cat` fails.

- **[P2] Preserve Cursor CLI behavior.** The `cursor()` function shadows any
  real CLI and handles only the first argument. Either rename the launcher or
  forward all arguments and flags correctly.

- **[P2] Fix the Pomodoro icon path.** `~` is quoted inside the alias command,
  so it may be passed literally to `terminal-notifier`. Use `$HOME` at runtime.

- **[P2] Split the 345-line `.zshrc`.** Suggested modules:
  `env.zsh`, `path.zsh`, `plugins.zsh`, `aliases.zsh`, `functions.zsh`,
  `completion.zsh`, and `local.zsh`. Keep personal/machine overlays ignored.

- **[P2] Cache theme conversion.** `theme.zsh` parses Lua and runs a Lua process
  during shell startup. Generate a small shell export file only when the theme
  definition changes.

- **[P2] Benchmark startup continuously.** Use a repeatable command such as
  `hyperfine 'zsh -i -c exit'`, set a budget, and record the median in the
  doctor output.

- **[P3] Reconsider `alias cd=z` and `alias ls=eza ...`.** They are pleasant,
  but wrappers/functions with graceful fallback preserve built-in behavior and
  make recovery shells easier.

## Yazi

- **[P0] Replace copied defaults with minimal overrides.** The 220-line
  `yazi.toml` and 355-line `keymap.toml` have drifted across multiple Yazi
  schema revisions. Start from `yazi --debug`/current defaults for 26.5.6 and
  keep only settings and bindings that differ.

- **[P1] Validate the complete config after migration.** Do not stop after
  removing `"$schema"`. Confirm open rules use the current `url`/`mime` shape,
  fetchers include required grouping, and all spotter/preloader/previewer keys
  match the installed release.

- **[P1] Make package dependencies reproducible.** `package.toml` already pins
  the Catppuccin flavor revision. Prefer restoring it with Yazi's package
  manager instead of committing the installed flavor directory and preview
  image.

- **[P1] Install or remove configured opener tools.** The config references
  `exiftool` and `mediainfo`, but neither command is installed or declared.

- **[Resolved] Keep Yazi macOS-only.** The migrated minimal configuration avoids
  copied Linux and Windows defaults. Future additions only need to support the
  owner's macOS environment.

## AeroSpace and SketchyBar

- **[P1] Restore or remove workspace indicators.** Source
  `items/aerospace.sh` from `sketchybarrc` if the README is correct; otherwise
  remove persistent workspaces and workspace-trigger plumbing that has no
  visible consumer.

- **[P1] Fix or remove Zen mode.** The active calendar click calls `zen.sh`,
  but Zen mode queries/sets items such as `wifi`, `apple.logo`, `mic`,
  `front_app`, Spotify, timer, volume, GitHub, and brew that are not created by
  the current bar.

- **[P1] Remove the Yabai/Kitty migration residue.** The repo says Yabai was
  removed, yet numerous item/plugin files still invoke Yabai and Kitty and
  reference `~/github/dotfiles-latest`. Archive genuinely reusable examples
  outside the live Stow package or delete them after review.

- **[P1] Normalize CPU percentage.** `cpu_simple.sh` sums every process's CPU
  across cores but compares the aggregate against single-core thresholds of
  10/30/70. Normalize by logical CPU count or label it as aggregate and choose
  thresholds based on maximum aggregate capacity.

- **[P1] Make network rate measurement time-based.** `network.sh` assumes every
  invocation is exactly two seconds apart. Store timestamp plus byte count,
  handle sleep/interface changes/counter resets, and use a user-specific file
  under `$TMPDIR` with safe creation and atomic replacement.

- **[P1] Remove the tracked ARM64 helper binary.** The compiled
  `helper/helper` is platform-specific and currently unused by the active
  `cpu_simple` item. Track source and build it during install only if the graph
  CPU item is restored.

- **[P1] Stop unloading the system OSD agent on every bar reload.**
  `sketchybarrc:17` changes system UI behavior as a side effect of reloading
  appearance config. Make this a documented, reversible, opt-in macOS setting
  or remove it.

- **[P2] Choose a primary terminal.** Codex opens projects in Ghostty, while
  AeroSpace's `Alt-T` opens WezTerm. Keep both if intentional, but document the
  roles; otherwise align the shortcut and app-to-workspace rules.

- **[P2] Add strict mode and dependency guards to active plugins.** Quote
  `$NAME` and other event variables, handle malformed command output, and
  return a visible fallback when `route`, `netstat`, `bc`, `pmset`, or
  SketchyBar is unavailable.

- **[P2] Reduce the bar's live surface.** Only five items are active while
  dozens of scripts are tracked. A small `enabled_items` manifest or one
  directory containing only active code will make future migrations far less
  confusing.

- **[P2] Separate quote data from executable shell.** This makes the plugin
  smaller, easier to curate, and easier to test for quoting/encoding problems.

## Neovim, Vim, and tmux

- **[P1] Commit `lazy-lock.json`.** Pair plugin updates with a reviewed lockfile
  diff and a headless smoke test.

- **[P1] Install the tools the config promises.** Mason currently has several
  language servers, but the configured formatters `prettier`, `ruff`, `black`,
  and `stylua` are not available to the audited shell, and `latex2text` is
  absent. Use `mason-tool-installer`, a Brewfile section, or project-local
  tools, then have `:checkhealth` report missing optional tools clearly.

- **[P1] Choose one Python formatter.** Running both `ruff_format` and `black`
  sequentially is redundant and can create churn. Pick one, or explicitly use
  “first available.”

- **[P1] Escape package names in `terminal.lua`.** JavaScript import strings are
  concatenated into a shell command when installing a package. Shell-escape
  parsed package names and prompted input, or execute argv without a shell.

- **[P1] Avoid fixed `/tmp/c_out` and `/tmp/cpp_out` binaries.** Use a secure
  unique temp path and clean it up. Fixed names permit collisions and unsafe
  symlink behavior.

- **[P1] Make LSP installation declarative.** The server list includes
  `ts_ls`, `rust_analyzer`, and `lua_ls`, but `mason.nvim` alone does not
  describe which tools a fresh machine must install. Add an explicit ensure
  list and a health check.

- **[P2] Simplify Lazy's plugin imports.** `plugins.lua` imports the whole
  `plugins` directory and then explicitly imports `plugins.tmux-navigator` and
  `plugins.conform`. Keep one discovery mechanism to avoid duplicate specs and
  unclear merge behavior.

- **[P2] Pin and validate the Lazy bootstrap.** Check clone errors, provide an
  actionable offline message, and consider pinning the bootstrap revision
  instead of following the moving `stable` branch.

- **[P2] Move the terminal/code-runner config off the `plenary.nvim` plugin
  spec.** Plenary is a shared library dependency; attaching unrelated global
  terminal configuration to its spec makes load order and spec merging harder
  to reason about.

- **[P2] Fix per-language runner semantics.** Run Java from the compiled class
  directory, find the Rust/Go project root, and make package-manager detection
  distinguish “install this project” from “add this imported dependency.”

- **[P2] Create the persistent undo directory in config.** Ensure
  `~/.vim/undodir` exists with private permissions before enabling `undofile`.

- **[P2] Remove generated `nvim.log` from Git and ignore root/editor logs.**
  The tracked file contains an old environment-specific server error and has
  no durable configuration value.

- **[P2] Decide whether classic Vim is a supported fallback.** If yes, lock its
  plugins and test startup. If not, shrink `.vimrc` to a dependency-free rescue
  config rather than maintaining a second plugin ecosystem.

- **[P2] Manage tmux-sessionizer.** Both tmux and Neovim depend on a manual
  `/usr/local/bin/sessionizer`. Add its installation, config, and version to
  the repo or replace the bindings with a small tracked script based on
  `ghq`/`fzf`.

- **[P2] Lock TPM plugins.** TPM follows moving plugin branches. Record tested
  revisions or add a controlled update/rollback workflow.

## pi, Codex, and shared skills

- **[P1] Unify pi packages with npm workspaces.** The root and extensions have
  multiple lockfiles and separate Effect installations. One workspace lock
  will prevent nominally incompatible duplicate classes and beta API drift.

- **[P1] Pin beta dependencies exactly.** Caret ranges on Effect 4 betas allowed
  root packages to move from beta.98 to beta.101 while extension trees remained
  on beta.98. Beta upgrades should be explicit and tested as a unit.

- **[P1] Align direct pi packages.** Direct `pi-ai`, `pi-tui`, and
  `pi-coding-agent` versions should match one release, or redundant direct
  dependencies should be removed if the coding agent is the supported public
  entry point.

- **[P1] Separate unit and live integration tests.** The audit ran 109 tests:
  105 passed, 2 Claude tests were skipped because Claude was unavailable, and
  2 live Codex tests failed because the restricted audit environment prevented
  Codex app-server PATH setup. Keep deterministic unit tests as the default and
  gate live backend tests behind an explicit integration command.

- **[P1] Fix formatting drift.** `npm run format:check` currently reports
  `extensions/subagents/index.ts` and `settings.json`.

- **[P1] Run `npm run check`, unit tests, and format checks together locally.**
  Do not update pi dependencies or settings unless these checks pass together.

- **[P1] Audit production dependencies online.** `npm audit` could not complete
  in the restricted audit environment, so vulnerability status remains
  unverified. Run it locally with network access during dependency updates and
  use a defined severity policy.

- **[P1] Keep volatile app state out of durable config.** Codex's marketplace
  timestamps, app version, trusted browser hashes, generated runtime paths,
  model migration notices, and pi's `lastChangelogVersion` create automatic
  churn. Track a curated template/overlay and leave machine-generated state
  local where the applications permit it.

- **[P1] Reconsider vendoring all installed skills.** `agents` and `pi` account
  for 1,272 tracked files and most repository bytes. Since a lock manifest
  already exists, consider restoring unchanged third-party skills from their
  pinned sources and tracking only the lock plus local/custom skills. If
  offline reproducibility matters more, keep vendoring but move it to a
  separate subtree/repository and mark it as vendored.

- **[P2] Add skill integrity verification.** Recompute each locked skill hash
  in the local doctor or update command, fail on unexplained changes, and
  produce a reviewable update report with source, old/new revision, license,
  and executable files.

- **[P2] Avoid installing every discovered skill dependency.** Install only
  dependencies for enabled/approved skills. This reduces supply-chain exposure,
  disk use, and the current roughly 1.1 GB `pi` working tree.

- **[P2] Make Codex notification optional and portable.** The notification
  executable is an absolute path inside machine-local `.codex` state and will
  not exist on a fresh machine unless separately installed.

- **[P2] Reconcile Codex service-tier settings.** Top-level
  `service_tier = "default"` and desktop
  `default-service-tier = "priority"` may be intentionally different; document
  the distinction or align them.

## Brewfile and update strategy

- **[P1] Make the Brewfile curated rather than a raw system dump.** Its header
  recommends `brew bundle dump --force`, which can reintroduce accidental
  packages and taps. Keep an intentional core manifest and optionally separate
  `Brewfile.desktop`, `Brewfile.work`, and `Brewfile.personal`.

- **[P1] Declare every required command.** Current gaps include
  `terminal-notifier`, tmux-sessionizer, Neovim formatters, `latex2text`,
  `exiftool`, and `mediainfo`. Conversely, remove dependencies that no active
  config uses.

- **[P1] Resolve runtime duplication.** Decide whether Node comes from Brew or
  NVM, Ruby from Brew or rbenv, and how Java versions are selected. The
  Brewfile, installer, shell, and updater should all express the same choice.

- **[P1] Make updates staged and recoverable.** `update.sh` upgrades nearly
  every global ecosystem in one run. Add phases, a pre-update version snapshot,
  a log, timeouts, optional major/greedy updates, and a final doctor. Stop
  dependent phases when a runtime update fails.

- **[P1] Add update coverage for externally cloned tools.** Oh My Zsh,
  Powerlevel10k, TPM plugins, NVM, Neovim plugins, Yazi packages, and shared
  skills are outside the updater even though they are part of the environment.
  Either include controlled update commands or state that each is manually
  pinned.

- **[P1] Do not mix “latest everywhere” with reproducible config.** Cargo and Go
  tools are reinstalled at latest versions while npm and agent dependencies
  have locks. Maintain a global tools manifest with source and version, then
  expose `update --latest` as an explicit choice.

- **[P2] Review taps.** Remove taps that no selected formula/cask requires, and
  prefer official/core formulas when they meet the need.

- **[P2] Define cask policy.** `--greedy` updates auto-updating and versioned
  casks. Make this opt-in because application updates can change config schemas
  immediately, as the Yazi drift demonstrates for CLI tools.

- **[P2] Add `brew bundle check --verbose` to the doctor.** Run it where
  Homebrew can access its cache. The audit sandbox could not complete this
  check, so Brewfile satisfaction was not conclusively verified.

- **[P2] Decide how to handle installed-but-untracked apps.** The machine has
  many casks not represented in the Brewfile. That is fine for a curated
  developer profile, but not if the goal is full machine reconstruction.

## Terminal, theme, and UI consistency

- **[P1] Create a single theme source of truth.** WezTerm owns the palette,
  Zsh parses the WezTerm Lua file, Ghostty duplicates the active palette, and
  Neovim maps terminal theme names to editor themes. Store theme data in one
  neutral file and generate/validate WezTerm, Ghostty, Neovim, SketchyBar,
  LazyGit, and Powerlevel10k outputs.

- **[P2] Propagate theme identity outside WezTerm.** `DOTFILES_THEME` is set by
  WezTerm, but Ghostty does not set it. Theme switching therefore behaves
  differently depending on which terminal launches Neovim.

- **[P2] Remove unused Ghostty snapshots.** `config-default` is a 2,522-line
  generated reference; `ghostty-theme` is not referenced and differs from the
  active config; the shader collection is not enabled. Keep documentation
  upstream and track only active configuration plus deliberately curated,
  licensed assets.

- **[P2] Add a contrast/readability check for transparent terminals.** Both
  terminals use 0.7 opacity. Keep it if preferred, but verify text, selections,
  diagnostics, and inactive panes over light and busy backgrounds.

- **[P3] Generate a theme preview.** A small script or screenshot grid showing
  ANSI colors, selection, diagnostics, Git status, and Markdown headings would
  make palette changes reviewable.

## Git and repository hygiene

- **[P1] Add `.editorconfig`.** Standardize UTF-8, LF, final newlines,
  indentation by language, and trailing whitespace.

- **[P1] Add `.gitattributes`.** Mark third-party skills, generated schemas,
  shader collections, lockfiles, and binary previews as vendored/generated or
  binary where appropriate. This improves diffs and repository language stats.

- **[P1] Keep generated state out of Git.** Remove `nvim.log`; review generated
  app timestamps/version fields; keep dependency directories ignored by both
  Git and Stow.

- **[P1] Replace “Changelog since last commit” in README.** That section became
  stale as soon as the changes were committed. Use Git history, release notes,
  or a real `CHANGELOG.md` with dated entries.

- **[P2] Add HTTPS clone instructions.** The quick start assumes an SSH key is
  already configured on a fresh machine.

- **[P2] Use conditional Git identity includes.** Keep a neutral global config,
  then select personal/work name, email, and signing key by repository path.

- **[P2] Make the GitHub credential helper portable.** The helper hard-codes
  `/opt/homebrew/bin/gh`. Resolve `gh` through a stable wrapper or generate the
  absolute path during local setup for Apple Silicon and Intel Macs.

- **[P2] Consider Git quality defaults.** Useful opt-ins include
  `fetch.prune`, `fetch.pruneTags`, `rerere.enabled`, commit signing,
  `diff.algorithm=histogram`, and Git maintenance/fsmonitor. Enable only after
  confirming the workflow and macOS/Git version.

- **[P2] Document ownership.** Distinguish authored config, copied defaults,
  generated state, vendored dependencies, and compiled artifacts. Each category
  should have a clear update mechanism.

## Testing and automation

- **[P1] Add a single `./doctor.sh` or `just audit` entry point** that performs:

  - Bash and Zsh syntax checks.
  - ShellCheck and `shfmt -d` on authored shell scripts.
  - TOML parsing plus application-aware validation.
  - Lua parsing/format checks and headless Neovim startup with isolated state.
  - JSON validation and a JSONC-aware validator for Zed.
  - `npm ci`, typecheck, deterministic unit tests, Prettier check, and audit.
  - Secret scanning of the worktree and history.
  - `stow -n` against a disposable HOME with runtime trees populated.
  - Broken-symlink, executable-bit, and missing-command checks.
  - README link and “documented feature is active” checks.

- **[Resolved] Keep validation local.** This is a personal macOS-only repository,
  so `doctor.sh` is the validation entry point and no hosted CI workflow is
  needed.

- **[P1] Test bootstrap idempotence.** In a disposable HOME: run install, run it
  again, verify the second plan has no changes, introduce file and symlink
  conflicts, verify backups, then test restore/uninstall.

- **[P1] Add config-schema regression tests.** Record tool versions and validate
  after dependency updates. Yazi is the clearest example of why TOML syntax
  alone is insufficient.

- **[P2] Add Renovate/Dependabot selectively.** Let it propose npm and pinned
  tool updates, but group coupled pi/Effect packages and require all checks.
  Skill/plugin updates need their own integrity-aware updater.

- **[P2] Add a command-manifest test.** Extract commands used by active configs
  and compare them to Brewfile/installer-provided commands or an explicit
  “manual/optional” allowlist.

## Validation notes from this audit

- Bash syntax checks passed for the bootstrap/updater and tracked SketchyBar
  shell scripts.
- Zsh syntax checks passed for `.zshrc`, `.zprofile`, `.zshenv`, and
  `theme.zsh`.
- Tracked TOML files pass a generic TOML parser, demonstrating why
  application-aware validation is still required: Yazi rejects its config.
- Tracked Lua files pass `luac -p`.
- Git config parses successfully.
- Atuin's doctor parsed the managed config successfully; its network portion
  was unavailable in the restricted audit environment.
- Neovim reached config startup, but the restricted environment prevented
  writes to its normal state/parser directories. Use an isolated writable XDG
  state/data fixture for a reliable local smoke test.
- `npm run check` fails on dependency/type skew.
- `npm run format:check` fails on two files.
- pi tests: 105 passed, 2 skipped, 2 live Codex tests failed for an
  environment-specific app-server restriction.
- `npm audit` and a complete `brew bundle check` could not be verified because
  the audit environment blocked required network/cache writes.

## Suggested execution order

### Phase 1: make it safe and truthful

- Remove blanket `curl` approval.
- Fix `dict()` injection.
- protect the secrets file.
- Add Stow ignores and safe conflict handling.
- Rebuild Yazi config.
- Align the README with the active SketchyBar implementation.

### Phase 2: make fresh installs reproducible

- Track Neovim's lockfile.
- Consolidate and pin pi dependencies.
- Use `npm ci`.
- Declare every required command.
- Pick one runtime/plugin manager per tool.
- Add install dry-run, profiles, doctor, restore, and uninstall.

### Phase 3: reduce accumulated surface area

- Remove copied defaults and inactive SketchyBar/Yabai/Kitty files.
- Stop tracking generated app state and `nvim.log`.
- Decide whether third-party skills remain vendored.
- Remove unused Ghostty assets/snapshots.
- Modularize shell configuration.

### Phase 4: keep it great

- Keep `doctor.sh` as an optional local macOS health check.
- Add controlled dependency/skill/plugin updates.
- Generate all themes from one source.
- Track startup time, config health, and idempotence as regression budgets.
