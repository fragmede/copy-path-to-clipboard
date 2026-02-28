#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Copy Path to Clipboard"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"
ASSETS_DIR="$SCRIPT_DIR/Assets"
ICONSET_DIR="$ASSETS_DIR/AppIcon.iconset"
ICON_NAME="CopyPathToClipboard"
ICON_FILE="$ASSETS_DIR/$ICON_NAME.icns"

echo "Building $APP_NAME..."

# Clean previous build
rm -rf "$APP_BUNDLE"

# Generate and package the app icon
mkdir -p "$ASSETS_DIR"
swift "$SCRIPT_DIR/scripts/generate_icon.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$ICON_FILE"

# Create app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy Info.plist
cp "$SCRIPT_DIR/Info.plist" "$APP_BUNDLE/Contents/"
cp "$ICON_FILE" "$APP_BUNDLE/Contents/Resources/"

# Compile Swift source
swiftc -o "$APP_BUNDLE/Contents/MacOS/CopyPathToClipboard" \
    "$SCRIPT_DIR/CopyPathToClipboard.swift" \
    -framework Cocoa

echo "Built: $APP_BUNDLE"
echo ""
echo "To install, copy the app to /Applications:"
echo "  cp -r \"$APP_BUNDLE\" /Applications/"
