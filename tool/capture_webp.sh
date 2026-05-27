#!/usr/bin/env bash
# Convert each PNG sequence captured by example/test/capture/capture_test.dart
# into an animated WebP suitable for embedding in README.md.
#
# Usage:
#   bash tool/capture_webp.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_DIR="${ROOT_DIR}/example/build/screenshots"
OUT_DIR="${ROOT_DIR}/screenshots"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found. Install via 'brew install ffmpeg' (macOS) or your package manager." >&2
  exit 1
fi

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "No PNGs found at ${SRC_DIR}." >&2
  echo "Run 'flutter test test/capture/capture_test.dart' from ./example first." >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"

for demo in basic_tilt gesture shake parallax dialog; do
  pattern="${SRC_DIR}/${demo}_%03d.png"
  out="${OUT_DIR}/${demo}.webp"
  if ! ls "${SRC_DIR}/${demo}_000.png" >/dev/null 2>&1; then
    echo "skip ${demo}: no frames" >&2
    continue
  fi
  echo "→ ${demo}"
  ffmpeg -y -loglevel error \
    -framerate 20 -i "${pattern}" \
    -vf "scale=480:-1:flags=lanczos" \
    -loop 0 -compression_level 6 -q:v 75 \
    "${out}"
  bytes=$(wc -c <"${out}" | tr -d ' ')
  printf '  wrote %s (%s bytes)\n' "${out}" "${bytes}"
done

echo "done."
