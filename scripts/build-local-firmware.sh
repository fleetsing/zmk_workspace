#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: build-local-firmware.sh [left|right|all]

Build the Totem firmware from the sibling zmk_config repo in a disposable west
workspace. Flashable UF2 artifacts are copied into zmk_workspace/artifacts/firmware
by default.

Environment:
  ZMK_BUILD_ROOT      Override the disposable build workspace root.
  ZMK_ARTIFACT_DIR    Override the local artifact output directory.
  ZMK_SKIP_UPDATE=1   Reuse the existing west workspace without fetching.
  ZMK_SKIP_PIP=1      Skip pip dependency installation after the venv exists.
  ZMK_EXTRA_MODULES   Optional semicolon-separated extra module paths.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$WORKSPACE_REPO/.." && pwd)"
CONFIG_REPO="$ROOT/zmk_config"
BUILD_ROOT="${ZMK_BUILD_ROOT:-${TMPDIR:-/tmp}/zmk-local-build}"
ARTIFACT_DIR="${ZMK_ARTIFACT_DIR:-$WORKSPACE_REPO/artifacts/firmware}"
VENV_DIR="$BUILD_ROOT/.venv"
CONFIG_DIR="$BUILD_ROOT/config"
PYTHON_BIN="${PYTHON_BIN:-python3}"
TARGET="${1:-all}"

case "$TARGET" in
  left)
    SHIELDS=(totem_left)
    ;;
  right)
    SHIELDS=(totem_right)
    ;;
  all)
    SHIELDS=(totem_left totem_right)
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

if [[ ! -d "$CONFIG_REPO/config" ]]; then
  echo "Missing config repo at $CONFIG_REPO" >&2
  exit 1
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "Missing Python executable: $PYTHON_BIN" >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required for disposable workspace syncs" >&2
  exit 1
fi

mkdir -p "$BUILD_ROOT"
mkdir -p "$ARTIFACT_DIR"

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

PIP="$VENV_DIR/bin/pip"
WEST="${WEST_BIN:-$VENV_DIR/bin/west}"
export PATH="$VENV_DIR/bin:$PATH"

if [[ "${ZMK_SKIP_PIP:-0}" != "1" ]]; then
  "$PIP" install --quiet --upgrade pip
  "$PIP" install --quiet west ninja pyelftools
elif [[ ! -x "$WEST" ]]; then
  WEST="$(command -v west || true)"
fi

if [[ ! -x "$WEST" ]]; then
  echo "west is not available. Re-run without ZMK_SKIP_PIP=1 or set WEST_BIN." >&2
  exit 1
fi

rsync -a --delete \
  --exclude '.git/' \
  --exclude '.venv/' \
  --exclude '.west/' \
  --exclude 'build/' \
  --exclude 'bootloader/' \
  --exclude 'modules/' \
  --exclude 'tools/' \
  --exclude 'zephyr/' \
  --exclude 'zmk/' \
  --exclude 'zmk-keyboard-totem/' \
  --exclude 'zmk-auto-layer/' \
  "$CONFIG_REPO"/ "$BUILD_ROOT"/

cd "$BUILD_ROOT"

if [[ ! -d .west ]]; then
  "$WEST" init -l config
fi

if [[ "${ZMK_SKIP_UPDATE:-0}" != "1" ]]; then
  "$WEST" update
fi

if [[ -n "${GNUARMEMB_TOOLCHAIN_PATH:-}" && -z "${ZEPHYR_TOOLCHAIN_VARIANT:-}" ]]; then
  export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
fi

if [[ -z "${ZEPHYR_TOOLCHAIN_VARIANT:-}" ]]; then
  GCC_BIN="$(command -v arm-none-eabi-gcc || true)"
  if [[ -n "$GCC_BIN" ]]; then
    export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
    export GNUARMEMB_TOOLCHAIN_PATH="$(cd "$(dirname "$GCC_BIN")/.." && pwd)"
  fi
fi

for shield in "${SHIELDS[@]}"; do
  build_name="${shield/totem_/totem-}"
  source_uf2="$BUILD_ROOT/build/$build_name/zephyr/zmk.uf2"
  artifact_uf2="$ARTIFACT_DIR/$build_name.uf2"
  cmake_args=(
    "-DSHIELD=$shield"
    "-DZMK_CONFIG=$CONFIG_DIR"
    "-DCMAKE_PREFIX_PATH=$BUILD_ROOT/zephyr"
  )

  if [[ -n "${ZMK_EXTRA_MODULES:-}" ]]; then
    cmake_args+=("-DZMK_EXTRA_MODULES=$ZMK_EXTRA_MODULES")
  fi

  "$WEST" build -p -d "build/$build_name" -b seeeduino_xiao_ble zmk/app -- "${cmake_args[@]}"
  cp "$source_uf2" "$artifact_uf2"
done

echo "Disposable build root: $BUILD_ROOT"
echo "Local artifact dir: $ARTIFACT_DIR"
for shield in "${SHIELDS[@]}"; do
  build_name="${shield/totem_/totem-}"
  echo "UF2: $ARTIFACT_DIR/$build_name.uf2"
done
