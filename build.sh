#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="${APP_NAME:-Pluggo}"
BIN_NAME="${BIN_NAME:-Pluginn}"
BUNDLE_ID="${BUNDLE_ID:-com.ibidi.Pluggo}"
VERSION="${VERSION:-0.1.0}"
BUILD_CONFIGURATION="${BUILD_CONFIGURATION:-release}"
CREATE_DMG=1

for arg in "$@"; do
  case "$arg" in
    --no-dmg)
      CREATE_DMG=0
      ;;
    --debug)
      BUILD_CONFIGURATION="debug"
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: ./build.sh [--no-dmg] [--debug]" >&2
      exit 1
      ;;
  esac
done

DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PLIST_TEMPLATE="$ROOT_DIR/Packaging/Info.plist.template"
PLIST_OUT="$CONTENTS_DIR/Info.plist"

mkdir -p "$DIST_DIR"

echo "==> Building Swift package ($BUILD_CONFIGURATION)"
swift build -c "$BUILD_CONFIGURATION"

BIN_CANDIDATES=(
  "$ROOT_DIR/.build/arm64-apple-macosx/$BUILD_CONFIGURATION/$BIN_NAME"
  "$ROOT_DIR/.build/x86_64-apple-macosx/$BUILD_CONFIGURATION/$BIN_NAME"
  "$ROOT_DIR/.build/$BUILD_CONFIGURATION/$BIN_NAME"
)

BIN_PATH=""
for candidate in "${BIN_CANDIDATES[@]}"; do
  if [[ -f "$candidate" ]]; then
    BIN_PATH="$candidate"
    break
  fi
done

if [[ -z "$BIN_PATH" ]]; then
  echo "Could not find built binary for $BIN_NAME" >&2
  exit 1
fi

echo "==> Creating app bundle"
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$BIN_PATH" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

if [[ ! -f "$PLIST_TEMPLATE" ]]; then
  echo "Missing Info.plist template at $PLIST_TEMPLATE" >&2
  exit 1
fi

sed \
  -e "s|__APP_NAME__|$APP_NAME|g" \
  -e "s|__BUNDLE_ID__|$BUNDLE_ID|g" \
  -e "s|__VERSION__|$VERSION|g" \
  "$PLIST_TEMPLATE" > "$PLIST_OUT"

if [[ -f "$ROOT_DIR/Packaging/AppIcon.icns" ]]; then
  cp "$ROOT_DIR/Packaging/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

if command -v codesign >/dev/null 2>&1; then
  echo "==> Ad-hoc signing app bundle"
  codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null 2>&1 || true
fi

echo "==> App bundle ready: $APP_BUNDLE"

if [[ "$CREATE_DMG" -eq 1 ]]; then
  if ! command -v hdiutil >/dev/null 2>&1; then
    echo "hdiutil not found; skipping DMG creation"
    exit 0
  fi

  DMG_PATH="$DIST_DIR/${APP_NAME}-${VERSION}.dmg"
  rm -f "$DMG_PATH"

  echo "==> Creating DMG"
  hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$APP_BUNDLE" \
    -ov \
    -format UDZO \
    "$DMG_PATH" >/dev/null

  echo "==> DMG ready: $DMG_PATH"
fi
