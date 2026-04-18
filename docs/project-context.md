# Project Context

This is the canonical agent-facing context document for the local Totem ZMK workspace.

## Purpose

Build and maintain a Totem keyboard setup with:

- a pinned upstream ZMK checkout for reference
- a separate `zmk_config` repo for the buildable user config
- separate out-of-tree module repos for shields, behaviors, and other custom logic
- a dedicated `zmk_workspace` repo for agent instructions, skills, scripts, and project documentation

## Local workspace layout

```text
~/zmk/
  zmk/            # upstream ZMK, pinned, reference only
  zmk_config/     # buildable user-config repo
  zmk_workspace/  # main Codex entrypoint and project docs
  zmk_modules/    # container for separate module repos
```

The root folder itself is a local umbrella workspace, not the main unit of version control.

## Agent startup model

- Start Codex from the `zmk_workspace` directory.
- Treat `zmk_workspace` as the main project repo for instructions and context.
- Treat `../zmk_config`, `../zmk`, and `../zmk_modules` as sibling project directories that are part of the same working context.
- The local Codex configuration in `zmk_workspace/.codex/config.toml` is intended to grant normal sessions started here write access to those sibling directories when the client honors project-local configuration.
- The helper launch scripts in `zmk_workspace/scripts/` are optional conveniences, not the primary workflow.

## Planned repo origins

- `zmk`: `https://github.com/zmkfirmware/zmk`
- `zmk_config`: `https://github.com/fleetsing/zmk_config`
- `zmk_workspace`: `https://github.com/fleetsing/zmk_workspace`

Each module under `zmk_modules/` should have its own repository.

## Keyboard targets

- Keyboard: Totem
- MCU: `seeeduino_xiao_ble`
- Shields:
  - `totem_left`
  - `totem_right`

## Physical layout

- Totem is a split, finger-splayed keyboard with three main rows, five main finger columns per half, and three thumb keys per half.
- Each half also has one extra outer key beyond the normal pinky column.
- The two inner columns are intended for the index finger, then middle, ring, and pinky moving outward.
- The outer extra key on each half is also a pinky key.
- See [totem_physical_layout.png](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/totem_physical_layout.png) for the reference image that explains the geometry better than the raw matrix alone.
- In `config/totem.keymap`, key positions are numbered sequentially in matrix order. This matters for positional hold-taps such as home-row mods.

## Host OS

- The current primary host OS is macOS.
- Default modifier ordering and shortcut ergonomics should be optimized for macOS first.
- A separate PC-oriented config may be added later, so do not assume modifier ordering is permanently cross-platform.

The current `zmk_config/config/west.yml` pulls the Totem shield from an out-of-tree module repo rather than from upstream ZMK. That matches the intended architecture: the shield should come from a module, not from direct edits to `zmk/`.

## Source-of-truth split

### `zmk_workspace`

Owns:

- agent operating rules
- local skills
- helper scripts
- project-level docs
- the explanation of how the sibling repos fit together

### `zmk_config`

Owns:

- `build.yaml`
- `config/west.yml`
- `config/totem.keymap`
- `config/totem_left.conf`
- `config/totem_right.conf`
- `config/totem.json`
- GitHub Actions workflows for firmware build and keymap drawing

### `zmk_modules`

Owns:

- reusable custom shield code
- behaviors
- drivers
- snippets
- other advanced out-of-tree logic

### `zmk`

Owns:

- pinned upstream firmware source
- pinned upstream docs
- optional local build/debug environment

## Non-negotiable rules

- Do not directly customize `zmk/` for normal project work.
- Keep the ZMK version pinned until an intentional upgrade is requested.
- Keep the GitHub build workflow pin aligned with the firmware pin.
- Prefer modules over stuffing advanced reusable logic into `config/totem.keymap`.
- Keep `config/totem.keymap` readable enough for Keymap Editor round-tripping.

## GitHub build model

Routine firmware builds should come from pushes to `zmk_config`.

Required pieces:

- `build.yaml` with the Totem build matrix
- `config/west.yml` with the pinned firmware revision and Totem module dependency
- `.github/workflows/build.yml` pinned to the same ZMK release as `config/west.yml`

## Keymap Editor model

The visual editing workflow is intentionally part of this setup.

To preserve it:

- keep the main keymap in `zmk_config/config/totem.keymap`
- keep layout metadata in `zmk_config/config/totem.json`
- avoid excessive preprocessor indirection in the main keymap
- move editor-hostile reusable logic into modules when it stops being pleasant in the keymap

## keymap-drawer model

Visualization is generated from `zmk_config` using the reusable `caksoylar/keymap-drawer` workflow.

Keep these stable unless intentionally changing the convention:

- keymap inputs: `config/*.keymap`
- optional DTS inputs: `config/*.dtsi`
- config file: `keymap_drawer.config.yaml`
- output folder: `keymap-drawer/`

## Local build commands

Canonical local verification path from `zmk_workspace`:

```bash
cd ~/zmk/zmk_workspace
./scripts/build-local-firmware.sh all
```

What the helper does:

- creates or reuses an isolated west workspace under `/tmp/zmk-local-build`
- syncs the current `zmk_config` repo into that disposable workspace
- installs `west`, `ninja`, and `pyelftools` into a local virtualenv
- prepends that virtualenv to `PATH` so the helper uses the same local `west` and `ninja`
- runs `west update` and the Totem builds
- auto-detects a Homebrew-style `arm-none-eabi-gcc` toolchain and exports `gnuarmemb` settings when possible

Useful variants:

```bash
./scripts/build-local-firmware.sh left
./scripts/build-local-firmware.sh right
ZMK_SKIP_UPDATE=1 ./scripts/build-local-firmware.sh all
ZMK_SKIP_UPDATE=1 ZMK_SKIP_PIP=1 ./scripts/build-local-firmware.sh all
```

Use `ZMK_SKIP_UPDATE=1` when reusing an already-fetched disposable workspace and you only want to confirm a config change locally without refetching dependencies.

In restricted sessions, the first run also needs network access so the disposable west workspace can fetch ZMK dependencies. Once that workspace has been populated, `ZMK_SKIP_UPDATE=1` can be used for local rebuilds without refetching.
If the disposable virtualenv already has the required Python packages, `ZMK_SKIP_PIP=1` can also be used to avoid pip refreshes in offline or network-restricted sessions.

## Expected build warnings

The current pinned `v0.3` stack may still emit a few non-blocking warnings during local builds.

- `NRF_STORE_REBOOT_TYPE_GPREGRET` deprecated:
  This is currently enabled by upstream ZMK on nRF52 in the pinned stack. It is not caused by the keymap or userspace config and should not be “fixed” locally unless the task is specifically about upstream/platform migration.
- Devicetree `label` deprecation warnings:
  Remaining `label` warnings are coming from board or module devicetree usage in the pinned stack, not from normal keymap customization. Treat them as upstream or module cleanup work.
- Devicetree `duplicate unit-address` warnings from generated `zephyr.dts`:
  These appear once `dtc` is available locally and come from board or module devicetree definitions in the pinned stack. Treat them as upstream or module cleanup work, not as a keymap regression.
- RWX `LOAD segment` linker warnings from `arm-none-eabi-ld.bfd`:
  These are common embedded-toolchain warnings for Zephyr firmware images and are not currently treated as a project-level bug.

If a new warning appears beyond the above list, treat it as potentially meaningful and inspect it.

## What to read first for most tasks

- `../zmk_config/build.yaml`
- `../zmk_config/config/west.yml`
- `../zmk_config/config/totem.keymap`
- `../zmk_config/config/totem_left.conf`
- `../zmk_config/config/totem_right.conf`
- `../zmk_config/config/totem.json`
- this file

## Current scaffold state

- `zmk_workspace` now has the project-level docs and agent entrypoint role
- `zmk_config` has build matrix, west manifest, keymap-drawer workflow, and Totem layout metadata
- `zmk_config` now has a minimal custom `config/totem.keymap` baseline rather than the original placeholder import
- home-row mods are being implemented with positional hold-tap tuning in the keymap itself
- `zmk_config` uses split side-specific Kconfig files: `config/totem_left.conf` and `config/totem_right.conf`
- `config/totem_right.conf` disables USB for the peripheral half, which keeps the split build valid in local testing and matches the intended runtime role
- `zmk_modules/` is a container only until module repos are cloned or created
