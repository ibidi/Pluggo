#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICONSET_DIR="$ROOT_DIR/.build/AppIcon.iconset"
OUTPUT_ICNS="$ROOT_DIR/Packaging/AppIcon.icns"
DOC_PNG="$ROOT_DIR/docs/assets/app-icon-1024.png"
README_LOGO="$ROOT_DIR/docs/assets/logo.png"

mkdir -p "$ICONSET_DIR" "$(dirname "$DOC_PNG")"
rm -f "$ICONSET_DIR"/*.png "$OUTPUT_ICNS"

swift "$ROOT_DIR/scripts/generate_icon.swift" "$ICONSET_DIR/icon_512x512@2x.png" 1024
cp "$ICONSET_DIR/icon_512x512@2x.png" "$DOC_PNG"
cp "$ICONSET_DIR/icon_512x512@2x.png" "$README_LOGO"

sips -z 16 16     "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32     "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32     "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64     "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128   "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256   "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256   "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512   "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512   "$ICONSET_DIR/icon_512x512@2x.png" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null

iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_ICNS"
echo "Generated: $OUTPUT_ICNS"
echo "Preview PNG: $DOC_PNG"
echo "README logo: $README_LOGO"
