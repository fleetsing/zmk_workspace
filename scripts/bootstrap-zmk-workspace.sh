#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_REPO_URL="${1:-https://github.com/fleetsing/zmk_config.git}"
ZMK_REF="${ZMK_REF:-v0.3}"
ZMK_REPO_URL="${ZMK_REPO_URL:-https://github.com/zmkfirmware/zmk.git}"

mkdir -p "$WORKSPACE_DIR/zmk_modules"

if [[ ! -d "$WORKSPACE_DIR/zmk/.git" ]]; then
  git clone "$ZMK_REPO_URL" "$WORKSPACE_DIR/zmk"
fi

git -C "$WORKSPACE_DIR/zmk" fetch --tags --quiet
git -C "$WORKSPACE_DIR/zmk" checkout "$ZMK_REF"

if [[ -n "$CONFIG_REPO_URL" && ! -d "$WORKSPACE_DIR/zmk_config/.git" ]]; then
  git clone "$CONFIG_REPO_URL" "$WORKSPACE_DIR/zmk_config"
fi

cat <<EOT
Workspace root: $WORKSPACE_DIR

Next steps:
  1. Confirm these nested repos/directories exist:
       $WORKSPACE_DIR/zmk
       $WORKSPACE_DIR/zmk_config
       $WORKSPACE_DIR/zmk_modules
  2. Review:
       $WORKSPACE_DIR/docs/project-context.md
       $WORKSPACE_DIR/zmk_config/config/west.yml
       $WORKSPACE_DIR/zmk_config/build.yaml
  3. Start your coding agent from:
       $WORKSPACE_DIR
     See "Agent tooling" in docs/project-context.md for per-tool setup.
  4. Verify the local build path with:
       $WORKSPACE_DIR/scripts/build-local-firmware.sh all
EOT
