---
name: keymap-editor-safe
description: Use this when a task changes the editor-facing ZMK keymap and should remain friendly to Nick Coutsos' Keymap Editor.
---

## Purpose

Protect the hybrid workflow: raw source editing, GitHub firmware builds, Keymap Editor compatibility, and keymap-drawer output from the same config repo.

## Rules

- Keep `../zmk_config/config/totem.keymap` as the editor-safe surface.
- Prefer direct, readable devicetree bindings over heavy alias indirection.
- Keep layout metadata in `../zmk_config/config/totem.json`.
- If a change becomes reusable or editor-hostile, move it into a module repo instead of growing the keymap complexity indefinitely.
- Say explicitly when a change risks Keymap Editor round-tripping.

## Good outcomes

- layers remain readable
- combos remain visual-editor friendly
- common macros remain understandable
- advanced behavior logic lives outside the main keymap when needed
