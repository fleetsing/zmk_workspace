# ZMK Workspace Agent Rules

Read [docs/project-context.md](/Users/jarnolouhelainen/Projects/keyboards/zmk/zmk_workspace/docs/project-context.md) before making substantial changes.

## Working directory model

- This repo, `zmk_workspace`, is the main agent entrypoint.
- Normal agent sessions should start from the `zmk_workspace` directory itself.
- Treat these sibling paths as in-scope project directories:
  - `../zmk_config`
  - `../zmk`
  - `../zmk_modules`
- If the local Codex client honors `zmk_workspace/.codex/config.toml`, those sibling directories should be writable roots for a normal session started here.

## Repository boundaries

- `../zmk` is a pinned upstream reference checkout.
- Do not edit `../zmk` unless the task explicitly says to patch upstream ZMK itself.
- Put keyboard-specific changes in `../zmk_config`.
- Put reusable behaviors, drivers, shields, snippets, widgets, and other out-of-tree logic in module repos under `../zmk_modules`.

## Totem-specific policy

- Keyboard target: Totem
- Board target: `seeeduino_xiao_ble`
- Build targets:
  - `totem_left`
  - `totem_right`

## Keymap policy

- Treat `../zmk_config/config/totem.keymap` as the editor-safe surface.
- Keep layers, combos, conditional layers, and visually edited macros there when possible.
- Avoid burying the keymap under heavy preprocessor aliasing if it would make Keymap Editor round-tripping fragile.
- Keep `../zmk_config/config/totem.json` local and stable for layout metadata.

## Build policy

- Prefer GitHub Actions builds from `../zmk_config` for routine firmware generation.
- Keep the workflow pin aligned with the ZMK pin in `../zmk_config/config/west.yml`.
- Use local builds mainly for CI debugging, module development, or migration work.
- For local builds, prefer `./scripts/build-local-firmware.sh` from this repo so `../zmk_config` stays free of `.west/` workspace state.
- The helper may keep its west workspace in a disposable temp location, but flashable UF2 files should land in a stable local folder under `zmk_workspace/artifacts/firmware/` unless a task explicitly overrides that path.

## Documentation policy

- Project-level operating docs belong in this repo.
- Repo-local config specifics belong in `../zmk_config`.
- If you change pins, layout conventions, repo boundaries, or normal commands, update the workspace docs here and any affected repo-local docs.
