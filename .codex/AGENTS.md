## ZMK workspace defaults

- Start from `../AGENTS.md` and `../docs/project-context.md`.
- The main agent repo is `zmk_workspace`, not `zmk_config`.
- A normal Codex session started in `zmk_workspace` should treat `../zmk_config`, `../zmk`, and `../zmk_modules` as in-scope sibling project directories.
- Treat `../zmk` as a pinned reference checkout unless explicitly asked to patch upstream ZMK itself.
- Prefer GitHub Actions builds from `../zmk_config` for routine firmware generation.
- Keep reusable custom logic in separate repos under `../zmk_modules`.
- Keep `../zmk_config/config/totem.keymap` readable enough for Keymap Editor round-tripping.
