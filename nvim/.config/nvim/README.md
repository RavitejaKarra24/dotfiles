# Neovim Config Quick Reference

This is a minimal coding-focused Neovim setup.

## Basics

- `Leader` key is `Space`
- Insert mode `jk` -> `Esc`
- Insert mode `<C-c>` -> `Esc`
- Disable Ex mode: `Q`

## File and Search

- `<leader>pv` -> file explorer (`:Ex`)
- `<leader>pf` -> find files (Telescope)
- `<C-p>` -> git files (Telescope)
- `<leader>ps` -> grep prompt (Telescope)
- `<leader>pg` -> live grep (Telescope)

## LSP Navigation

These work when an LSP is attached (Rust, TS, Lua).

- `gd` -> definition
- `gD` -> declaration
- `gi` -> implementation
- `gr` -> references
- `K` -> hover docs
- `<leader>ca` -> code action
- `<leader>rn` -> rename symbol
- Insert mode `<C-h>` -> signature help

## Diagnostics (Errors/Warnings)

- `gl` -> show diagnostic at cursor
- `<leader>e` -> show diagnostic at cursor
- `[d` -> previous diagnostic
- `]d` -> next diagnostic
- `<leader>q` -> diagnostics list (location list)
- `<leader>ec` -> copy diagnostic on current line
- `<leader>ea` -> copy all diagnostics in current buffer

## Formatting

- `<leader>f` -> LSP format
- `<leader>cf` -> Conform format

## Quickfix and Location List

- `<C-k>` -> next quickfix item
- `<C-j>` -> previous quickfix item
- `<leader>k` -> next location list item
- `<leader>j` -> previous location list item

## Editing Helpers

- Visual `J` -> move selected lines down
- Visual `K` -> move selected lines up
- Normal `J` -> join lines and keep cursor centered
- `<C-d>` / `<C-u>` -> half-page move with centered cursor
- `n` / `N` -> next/prev search result with centered cursor
- `<leader>p` (visual) -> paste without overwriting default register
- `<leader>y` / `<leader>Y` -> copy to system clipboard
- `<leader>d` -> delete to void register
- `<leader>s` -> substitute word under cursor
- `<leader>x` -> `chmod +x` current file

## Terminal

- `<leader>th` -> terminal in horizontal split
- `<leader>tv` -> terminal in vertical split
- `<leader>tt` -> terminal in current window
- Terminal mode `<Esc>` -> normal mode
- `q` in terminal buffer (normal mode) -> close terminal

## Code Runner

- `<leader>rr` -> run current file (auto-detects language)
- `<leader>rc` -> run a custom command (prompts for input)

Supported: JavaScript (node), TypeScript (bun), Python, Rust (cargo), Go, C, C++, Lua, Shell, Ruby, Java. Add more in `run_commands` table in `terminal.lua`.

## Package Installer

- `<leader>ri` -> install package from import line under cursor (auto-detects package manager)
- `<leader>ra` -> add a package by name (prompts for input, auto-detects package manager)

Detects: bun, pnpm, yarn, npm, pip, cargo, go modules.

## Git / Tools

- `<leader>gs` -> Fugitive `:Git`
- `<leader>u` -> Undotree toggle
- `<leader>a` -> Harpoon add file
- `<C-e>` -> Harpoon quick menu
- `<leader>1` / `<leader>2` / `<leader>3` / `<leader>4` -> jump to Harpoon file
- `<leader>mr` -> RenderMarkdown toggle
- `<leader>me` -> RenderMarkdown enable
- `<leader>md` -> RenderMarkdown disable

## Config Shortcuts

- `<leader>vpp` -> open `init.lua`
- `<leader>vpl` -> open plugins folder
- `<leader><leader>` -> source current file

## Rust Completion Note

For variable methods use `.` not `::`.

- `s1.` -> instance methods (what you usually want)
- `String::` -> associated functions on the type

If completion popup does not open automatically, press `<C-Space>`.
