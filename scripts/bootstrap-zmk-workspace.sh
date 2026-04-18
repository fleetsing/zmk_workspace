#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="${1:-$(cd "$WORKSPACE_DIR/.." && pwd)}"
CONFIG_REPO_URL="${2:-https://github.com/fleetsing/zmk_config.git}"
ZMK_REF="${ZMK_REF:-v0.3}"
ZMK_REPO_URL="${ZMK_REPO_URL:-https://github.com/zmkfirmware/zmk.git}"

mkdir -p "$ROOT"/zmk_workspace/.codex
mkdir -p "$ROOT"/zmk_workspace/scripts
mkdir -p "$ROOT"/zmk_modules

if [[ ! -d "$ROOT/zmk/.git" ]]; then
  git clone "$ZMK_REPO_URL" "$ROOT/zmk"
fi

git -C "$ROOT/zmk" fetch --tags --quiet
git -C "$ROOT/zmk" checkout "$ZMK_REF"

if [[ -n "$CONFIG_REPO_URL" && ! -d "$ROOT/zmk_config/.git" ]]; then
  git clone "$CONFIG_REPO_URL" "$ROOT/zmk_config"
fi

cat <<EOF
Workspace root: $ROOT

Next steps:
  1. Confirm these sibling repos/directories exist:
       $ROOT/zmk
       $ROOT/zmk_config
       $ROOT/zmk_workspace
       $ROOT/zmk_modules
  2. Review:
       $ROOT/zmk_workspace/docs/project-context.md
       $ROOT/zmk_config/config/west.yml
       $ROOT/zmk_config/build.yaml
  3. Start Codex with:
       $ROOT/zmk_workspace/scripts/codex-zmk
  4. Verify the local build path with:
       $ROOT/zmk_workspace/scripts/build-local-firmware.sh all
EOF
