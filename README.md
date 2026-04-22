# zmk_workspace

This repository is the main Codex and documentation entrypoint for the Totem ZMK setup.

Agents should be launched from here so they start with the right project context, the right repo boundaries, and access to the sibling repos that actually contain the config, the pinned firmware source, and any out-of-tree modules.

## Normal startup

The intended day-to-day flow is to `cd` into `zmk_workspace` and start `codex` normally from there.

The critical rules live in [AGENTS.md](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/AGENTS.md) and [docs/project-context.md](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/docs/project-context.md). The local Codex config in [`.codex/config.toml`](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/.codex/config.toml) is set up so that, when honored by the client, sibling access includes:

- `../zmk_config`
- `../zmk`
- `../zmk_modules`

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

## Helper scripts

- [scripts/bootstrap-zmk-workspace.sh](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/scripts/bootstrap-zmk-workspace.sh)
  - optional bootstrap helper that clones the pinned upstream `zmk` checkout and a `zmk_config` repo into the expected sibling layout
- [scripts/codex-zmk](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/scripts/codex-zmk)
  - optional wrapper for normal daily config work with `zmk_config` and `zmk_modules` added as sibling dirs when present
- [scripts/codex-zmk-ref](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/scripts/codex-zmk-ref)
  - optional wrapper that also adds the pinned `../zmk` checkout for upstream reference work
- [scripts/codex-zmk-live](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/scripts/codex-zmk-live)
  - optional wrapper that starts the `zmk-research` profile for research or upgrade sessions that need network access
- [scripts/build-local-firmware.sh](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/scripts/build-local-firmware.sh)
  - disposable local Totem build wrapper for `zmk_config`

## Current intent

- keep upstream ZMK pinned at `v0.3`
- keep GitHub firmware builds in `zmk_config`
- keep `config/totem.keymap` compatible with Keymap Editor where practical
- keep keymap-drawer outputs generated from the `zmk_config` repo
- keep the live Totem config centered on the MacOS base layer, transparent PC overlays, combo-driven AutoNav/AutoNum flows, and separate Media/Mouse/Board utility layers

## Local build

Use the workspace helper instead of running `west init` inside `zmk_config`:

```bash
./scripts/build-local-firmware.sh all
```

This mirrors the `zmk_config` manifest in a disposable west workspace under `${TMPDIR:-/tmp}/zmk-local-build` by default, so local verification does not leave `.west/` state in the config repo.
The helper then copies the flashable UF2 files into `artifacts/firmware/` in this repo so they remain easy to find after the build.

Useful variants:

```bash
./scripts/build-local-firmware.sh left
./scripts/build-local-firmware.sh right
ZMK_SKIP_UPDATE=1 ./scripts/build-local-firmware.sh all
ZMK_SKIP_UPDATE=1 ZMK_SKIP_PIP=1 ./scripts/build-local-firmware.sh all
ZMK_EXTRA_MODULES="/abs/path/to/module-one;/abs/path/to/module-two" ./scripts/build-local-firmware.sh all
```
