---
name: draw-keymaps
description: Use this when a task changes keymap layers, combos, legends, or diagram paths and the keymap-drawer workflow may need to stay in sync.
---

## Purpose

Keep the visualization pipeline in `../zmk_config` aligned with the actual keymap files.

## Checklist

1. Inspect:
   - `../zmk_config/config/*.keymap`
   - `../zmk_config/.github/workflows/draw-keymaps.yml`
   - `../zmk_config/keymap_drawer.config.yaml`
   - `../zmk_config/keymap-drawer/`
2. If filenames or output paths changed, update the workflow inputs too.
3. Prefer the reusable `caksoylar/keymap-drawer` workflow pattern.
4. Keep generated output under `keymap-drawer/` unless intentionally changing the convention.
5. Summarize diagram-impacting changes clearly.
