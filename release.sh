#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Copy Path to Clipboard"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"
INFO_PLIST="$SCRIPT_DIR/Info.plist"
DIST_DIR="$SCRIPT_DIR/dist"
NOTARIZATION_LOG="$DIST_DIR/notarization-result.json"

SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application: samson yeung (8874HJ98MD)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-notarytool-profile}"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
ARCHIVE_BASENAME="CopyPathToClipboard-${VERSION}-macos"
SUBMISSION_ARCHIVE="$DIST_DIR/${ARCHIVE_BASENAME}-notarize.zip"
RELEASE_ARCHIVE="$DIST_DIR/${ARCHIVE_BASENAME}.zip"

echo "Preparing signed release for $APP_NAME $VERSION..."

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

"$SCRIPT_DIR/build.sh"

# Clear extended attributes before signing to keep the bundle deterministic.
xattr -cr "$APP_BUNDLE"

echo "Signing app bundle with: $SIGN_IDENTITY"
codesign \
  --force \
  --deep \
  --timestamp \
  --options runtime \
  --sign "$SIGN_IDENTITY" \
  "$APP_BUNDLE"

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

echo "Creating notarization archive..."
ditto -c -k --keepParent --sequesterRsrc "$APP_BUNDLE" "$SUBMISSION_ARCHIVE"

echo "Submitting archive for notarization with profile: $NOTARY_PROFILE"
SUBMISSION_RESULT="$(xcrun notarytool submit "$SUBMISSION_ARCHIVE" --keychain-profile "$NOTARY_PROFILE" --wait --output-format json)"
printf '%s\n' "$SUBMISSION_RESULT" > "$NOTARIZATION_LOG"

NOTARIZATION_STATUS="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["status"])' < "$NOTARIZATION_LOG")"
if [[ "$NOTARIZATION_STATUS" != "Accepted" ]]; then
  echo "Notarization failed with status: $NOTARIZATION_STATUS"
  exit 1
fi

echo "Stapling notarization ticket..."
xcrun stapler staple "$APP_BUNDLE"
xcrun stapler validate "$APP_BUNDLE"

echo "Running Gatekeeper assessment..."
spctl -a -vv --type exec "$APP_BUNDLE"

echo "Creating release archive..."
rm -f "$RELEASE_ARCHIVE"
ditto -c -k --keepParent --sequesterRsrc "$APP_BUNDLE" "$RELEASE_ARCHIVE"
rm -f "$SUBMISSION_ARCHIVE"

echo "Release archive ready:"
echo "  $RELEASE_ARCHIVE"
echo "Notarization result saved to:"
echo "  $NOTARIZATION_LOG"
