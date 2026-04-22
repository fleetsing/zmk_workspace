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
- `scripts/bootstrap-zmk-workspace.sh` can create the expected sibling layout from scratch when bootstrapping a new local workspace.

## Repo origins

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
- The current keymap already includes PC-oriented transparent overlay layers, but macOS remains the default baseline for modifier choices and workflow assumptions.

The current `zmk_config/config/west.yml` pins the Totem shield from an out-of-tree module repo rather than from upstream ZMK, and also pins the `urob/zmk-auto-layer` module for smart layer behaviors. That matches the intended architecture: reusable firmware features should come from modules, not from direct edits to `zmk/`.

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
- `config/totem.conf.example`
- `config/totem.keymap.example`
- GitHub Actions workflows for firmware build and keymap drawing
- `keymap_drawer.config.yaml`
- `scripts/update-totem-json.sh`
- repo-local docs under `docs/`

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

## Current Totem config state

- `config/totem.keymap` currently defines thirteen layers:
  `MacOS`, `PC`, `Nav`, `Nav `, `AutoNav`, `Num`, `Num `, `AutoNum`, `Fun`, `Fun `, `Media`, `Mouse`, and `Board`.
- `PC` is a transparent base overlay that swaps the relevant GUI and Control home-row holds for PC use, and `Nav `, `Num `, and `Fun ` are matching transparent PC-specific overlays activated through conditional layers.
- The keymap now has two combo-driven auto-layer paths:
  `combo_nav_layer` enters `AutoNav` through a custom `nav_word` auto-layer behavior, and `combo_num_layer` enters `AutoNum` through the module-provided `num_word` behavior.
- The live keymap keeps a larger set of inline behaviors than the older docs described:
  `Meh` and `Hyper` macros, left/right home-row hold-taps, left/right bottom-row `Meh`/`Hyper` hold-taps, `lts`, `ss`, `htc`, `nav_word`, and the transparent-hold helpers `mht`, `hypht`, and `mehht`.
- Hold-tap tuning is split by role rather than shared globally:
  the home-row and bottom-row modifier helpers use `balanced`, `quick-tap-ms = 175`, `require-prior-idle-ms = 150`, `retro-tap`, and `hold-trigger-on-release`, while `htc` and the transparent-hold helpers have their own tighter tap-preferred or tap-unless-interrupted tuning.
- The layer stack now includes dedicated utility layers beyond the older summary:
  `Media` for host media controls, `Mouse` for pointer and scroll actions, and `Board` for Bluetooth selection and output switching.
- `config/totem_left.conf` disables USB logging and enables the central-side BLE battery reporting settings used by host-side battery apps.
- `config/totem_right.conf` disables USB, the USB device stack, and the nRF USB driver on the peripheral half.
- `config/totem.json` remains the local layout metadata source for the 38-key Totem geometry used by Keymap Editor and keymap-drawer.
- `config/totem.conf.example` and `config/totem.keymap.example` are templates only; they are not part of the live build inputs.

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

- creates or reuses an isolated west workspace under `${TMPDIR:-/tmp}/zmk-local-build` unless `ZMK_BUILD_ROOT` is set
- syncs the current `zmk_config` repo into that disposable workspace
- installs `west`, `ninja`, and `pyelftools` into a local virtualenv
- prepends that virtualenv to `PATH` so the helper uses the same local `west` and `ninja`
- runs `west update` and the Totem builds
- copies the resulting UF2 files into `zmk_workspace/artifacts/firmware/` unless `ZMK_ARTIFACT_DIR` is set
- auto-detects a Homebrew-style `arm-none-eabi-gcc` toolchain and exports `gnuarmemb` settings when possible

Useful variants:

```bash
./scripts/build-local-firmware.sh left
./scripts/build-local-firmware.sh right
ZMK_SKIP_UPDATE=1 ./scripts/build-local-firmware.sh all
ZMK_SKIP_UPDATE=1 ZMK_SKIP_PIP=1 ./scripts/build-local-firmware.sh all
ZMK_ARTIFACT_DIR=$PWD/firmware ./scripts/build-local-firmware.sh all
ZMK_EXTRA_MODULES="/abs/path/to/module-one;/abs/path/to/module-two" ./scripts/build-local-firmware.sh all
```

Use `ZMK_SKIP_UPDATE=1` when reusing an already-fetched disposable workspace and you only want to confirm a config change locally without refetching dependencies.
Use `ZMK_ARTIFACT_DIR` when you want the flashable UF2 files copied somewhere other than the default workspace-local artifact folder.
Use `ZMK_EXTRA_MODULES` when a local build needs additional out-of-tree modules that are not already pinned in `config/west.yml`.

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
- `../zmk_config/keymap_drawer.config.yaml`
- `../zmk_config/docs/zmk-context.md`
- this file

## Current workspace state

- `zmk_workspace` owns the project-level docs, agent entrypoint role, local skills, and helper scripts.
- `zmk_config` owns the live Totem build matrix, west manifest, keymap, side-specific `.conf` files, layout metadata, and GitHub Actions workflows.
- `zmk_config/config/totem.keymap` is no longer a starter baseline; it is the maintained editor-safe source for the current multi-layer layout and custom hold-tap behavior definitions.
- `zmk_modules/` is still the place to move reusable or editor-hostile logic once it no longer fits comfortably in the main keymap.
