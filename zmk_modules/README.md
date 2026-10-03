# zmk_modules

This directory is a container for out-of-tree ZMK module repositories.

It is not the main source of truth by itself. Each child directory should be its own repository.

## Intended contents

- keyboard/shield modules
- custom behaviors
- drivers
- snippets
- display or lighting features

## Rules

- keep reusable logic here, not in `zmk/` (the pinned upstream checkout)
- do not turn `zmk_config/config/totem.keymap` into a module dump
- pin module dependencies in `zmk_config/config/west.yml`
