# zmk_workspace

This repository is the main Codex and documentation entrypoint for the Totem ZMK setup.

Agents should be launched from here so they start with the right project context, the right repo boundaries, and access to the sibling repos that actually contain the config, the pinned firmware source, and any out-of-tree modules.

## Scope

- Own the project-level documentation and operating model
- Own agent instructions, local skills, and helper scripts
- Do not store the actual keymap/config here
- Do not store custom ZMK module source here

## Sibling repos

```text
../zmk           pinned upstream ZMK checkout
../zmk_config    buildable user-config repo
../zmk_modules   container for module repos
```

## Primary docs

- [AGENTS.md](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/AGENTS.md)
- [docs/project-context.md](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/docs/project-context.md)

## Launcher scripts

- [scripts/codex-zmk](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/scripts/codex-zmk)
  - normal daily config work
- [scripts/codex-zmk-ref](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/scripts/codex-zmk-ref)
  - daily work plus access to the pinned `../zmk` reference checkout
- [scripts/codex-zmk-live](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/scripts/codex-zmk-live)
  - research or upgrade sessions that need live web access

## Current intent

- keep upstream ZMK pinned at `v0.3`
- keep GitHub firmware builds in `zmk_config`
- keep `config/totem.keymap` compatible with Keymap Editor where practical
- keep keymap-drawer outputs generated from the `zmk_config` repo
