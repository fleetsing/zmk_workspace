---
name: totem-keymap-workflow
description: Use this when editing the Totem layout or hold-tap behavior and the task needs the project-specific physical layout, macOS modifier assumptions, and keymap conventions.
---

## Purpose

Keep Totem keymap changes aligned with this workspace's actual operating assumptions instead of treating the board like a generic split keyboard.

## Read first

- `../docs/project-context.md`
- `../../zmk_config/docs/zmk-context.md`
- `../../zmk_config/config/totem.keymap`

## Core context

- Totem is a finger-splayed split board with `3x5+3` core keys plus one extra outer pinky key per half.
- The two inner columns are index columns, then middle, ring, and pinky moving outward.
- The current primary host OS is macOS.
- `../totem_physical_layout.png` is the quick reference for geometry.

## Keymap rules

- Keep `../../zmk_config/config/totem.keymap` as the editor-safe surface.
- Favor readable direct bindings over heavy indirection.
- Keep layout metadata in `../../zmk_config/config/totem.json`.
- Say explicitly when a change may hurt Keymap Editor round-tripping.

## Current conventions

- Home-row mods live on the stronger fingers, not the pinkies.
- Current HRM tuning uses positional hold-tap with `balanced`, `require-prior-idle-ms`, `quick-tap-ms`, `retro-tap`, and `hold-trigger-on-release`.
- `Meh` and `Hyper` currently live as bottom-row hold-taps and follow the same tuning style as the HRMs.
- The current PC support model is transparent overlay layers that only swap the relevant GUI and Control holds instead of duplicating full PC-specific copies of each layer.

## Checks

- Rebuild with `./scripts/build-local-firmware.sh all` after keymap changes.
- If layers, legends, or file paths change, also apply the `draw-keymaps` skill.
