# zmk_workspace

This repository is the workspace root and the main agent and documentation entrypoint for the Totem ZMK setup.

The repos that contain the config, the pinned firmware source, and any out-of-tree modules are cloned inside it as nested repos. Agents launched from here start with the right project context, the right repo boundaries, and access to all of them.

## Setup

```bash
git clone https://github.com/fleetsing/zmk_workspace.git
cd zmk_workspace
./scripts/bootstrap-zmk-workspace.sh
```

The bootstrap script clones the pinned upstream `zmk` checkout and the `zmk_config` repo into the workspace and creates `zmk_modules/`.

## Normal startup

`cd` into the workspace root and start your coding agent (Claude Code, Codex, or another `AGENTS.md`-aware tool) from there. Permission rules are anchored at the workspace root, so start sessions there rather than inside a nested repo.

The critical rules live in [AGENTS.md](AGENTS.md) and [docs/project-context.md](docs/project-context.md). The per-tool adapters ([`.claude/settings.json`](.claude/settings.json), [`.codex/config.toml`](.codex/config.toml)) let agents edit `zmk_config/` and `zmk_modules/`, and ask for confirmation before editing the pinned `zmk/` checkout. See "Agent tooling" in [docs/project-context.md](docs/project-context.md) for which files are shared and which are tool-specific.

## Scope

- Own the project-level documentation and operating model
- Own agent instructions, local skills, and helper scripts
- Do not store the actual keymap/config here
- Do not store custom ZMK module source here

## Nested repos

```text
zmk/           pinned upstream ZMK checkout
zmk_config/    buildable user-config repo
zmk_modules/   container for module repos
```

Each is its own git repository, ignored by this repo. Run git commands inside the nested repo, for example `git -C zmk_config status`.

## Primary docs

- [AGENTS.md](AGENTS.md)
- [docs/project-context.md](docs/project-context.md)

## Helper scripts

- [scripts/bootstrap-zmk-workspace.sh](scripts/bootstrap-zmk-workspace.sh)
  - clones the pinned upstream `zmk` checkout and a `zmk_config` repo into the workspace
- [scripts/build-local-firmware.sh](scripts/build-local-firmware.sh)
  - disposable local Totem build wrapper for `zmk_config`

Optional Codex launchers under [scripts/agents/](scripts/agents/). For daily work, plain `codex` from the workspace root is enough.

- `codex-zmk-ref`: makes the pinned `zmk/` checkout writable for upstream work
- `codex-zmk-live`: also adds live web search and network access for research or upgrade sessions

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
