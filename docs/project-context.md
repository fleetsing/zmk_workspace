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
- `config/totem.conf`
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

Prepare the pinned ZMK checkout once:

```bash
cd ~/zmk/zmk
python3 -m venv .venv
source .venv/bin/activate
pip install west
west init -l app/
west update
west zephyr-export
west packages pip --install
```

Build the left half from the config repo:

```bash
cd ~/zmk/zmk/app
west build -d build/totem-left -b seeeduino_xiao_ble -- \
  -DSHIELD=totem_left \
  -DZMK_CONFIG="$HOME/zmk/zmk_config/config"
```

Build with extra modules:

```bash
cd ~/zmk/zmk/app
west build -d build/totem-left -b seeeduino_xiao_ble -- \
  -DSHIELD=totem_left \
  -DZMK_CONFIG="$HOME/zmk/zmk_config/config" \
  -DZMK_EXTRA_MODULES="$HOME/zmk/zmk_modules"
```

Repeat for `totem_right` when needed.

## What to read first for most tasks

- `../zmk_config/build.yaml`
- `../zmk_config/config/west.yml`
- `../zmk_config/config/totem.keymap`
- `../zmk_config/config/totem.conf`
- `../zmk_config/config/totem.json`
- this file

## Current scaffold state

- `zmk_workspace` now has the project-level docs and agent entrypoint role
- `zmk_config` has build matrix, west manifest, keymap-drawer workflow, and Totem layout metadata
- `zmk_config` still needs real `config/totem.keymap` and `config/totem.conf` content before the keyboard-specific setup is complete
- `zmk_modules/` is a container only until module repos are cloned or created
