---
name: local-build
description: Use this when a task needs a local ZMK build, especially for CI debugging, external module work, or verifying a Totem configuration change against the pinned upstream checkout.
---

## Purpose

Run or propose local build commands for the Totem workspace without treating `../zmk` as the place to store project-specific changes.

## Assumptions

- main agent repo: `../zmk_workspace`
- upstream checkout: `../zmk`
- config repo: `../zmk_config`
- module repos: `../zmk_modules/*`

## Canonical commands

### Prepare local checkout

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

### Build Totem left

```bash
cd ~/zmk/zmk/app
west build -d build/totem-left -b seeeduino_xiao_ble -- \
  -DSHIELD=totem_left \
  -DZMK_CONFIG="$HOME/zmk/zmk_config/config"
```

### Build Totem left with modules

```bash
cd ~/zmk/zmk/app
west build -d build/totem-left -b seeeduino_xiao_ble -- \
  -DSHIELD=totem_left \
  -DZMK_CONFIG="$HOME/zmk/zmk_config/config" \
  -DZMK_EXTRA_MODULES="$HOME/zmk/zmk_modules"
```

Repeat for `totem_right` when needed.

## Rules

- Do not treat local build success as permission to patch upstream `../zmk`.
- If a feature is reusable or shield-specific, prefer creating or updating a module under `../zmk_modules`.
- Keep the local build assumptions aligned with `../zmk_config/config/west.yml` and `../zmk_config/build.yaml`.
