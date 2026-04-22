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

### Build both halves

```bash
cd ~/zmk/zmk_workspace
./scripts/build-local-firmware.sh all
```

Flashable outputs are copied to `~/zmk/zmk_workspace/artifacts/firmware/` by default.

### Build one half

```bash
cd ~/zmk/zmk_workspace
./scripts/build-local-firmware.sh left
./scripts/build-local-firmware.sh right
```

### Reuse an existing fetched workspace

```bash
cd ~/zmk/zmk_workspace
ZMK_SKIP_UPDATE=1 ./scripts/build-local-firmware.sh all
```

### Override the artifact folder

```bash
cd ~/zmk/zmk_workspace
ZMK_ARTIFACT_DIR=$PWD/firmware ./scripts/build-local-firmware.sh all
```

## Rules

- Do not treat local build success as permission to patch upstream `../zmk`.
- If a feature is reusable or shield-specific, prefer creating or updating a module under `../zmk_modules`.
- Keep the local build assumptions aligned with `../zmk_config/config/west.yml` and `../zmk_config/build.yaml`.
- Prefer the workspace helper over running `west init` inside `../zmk_config`.
- Treat the copied UF2 files under `zmk_workspace/artifacts/firmware/` as the normal local flashing outputs unless the task explicitly overrides the artifact directory.
