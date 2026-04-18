---
name: zmk-module-workflow
description: Use this when a task may need a reusable ZMK module, a new repo under ../zmk_modules, or manifest wiring in ../zmk_config/config/west.yml instead of putting more logic in the keymap.
---

## Purpose

Keep the repo boundary clean: user-facing layout work in `../zmk_config`, reusable firmware logic in `../zmk_modules`, and upstream ZMK in `../zmk` as a pinned reference.

## Use this skill when

- a change is becoming too complex or editor-hostile for `../zmk_config/config/totem.keymap`
- the task needs a reusable behavior, shield tweak, snippet, driver, or widget
- a module repo must be created, cloned, or wired into the manifest

## Rules

- Do not patch `../zmk` for normal project work.
- Prefer `../zmk_config` for layers, combos, simple hold-taps, and editor-facing macros.
- Prefer `../zmk_modules` for reusable logic or anything that would make the keymap hard to round-trip in Keymap Editor.
- Treat each module under `../zmk_modules` as its own repository.

## Workflow

1. Decide whether the change belongs in `../zmk_config` or a module.
2. If it belongs in a module, create or update the repo under `../zmk_modules/<module-name>`.
3. Wire the module through `../zmk_config/config/west.yml` instead of relying on manual local state.
4. Keep project docs in `../zmk_workspace` and repo-local details in `../zmk_config`.
5. Verify with `./scripts/build-local-firmware.sh all` from `zmk_workspace`.

## Checks

- `../zmk_config/config/west.yml`
- `../zmk_workspace/docs/project-context.md`
- `../zmk_config/docs/zmk-context.md`
