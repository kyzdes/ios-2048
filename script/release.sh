#!/bin/bash
set -euo pipefail

#───────────────────────────────────────────────────────────
# Game2048 Mac — Release Script
#
# Builds, signs, notarizes, creates a DMG and a ZIP for a
# GitHub Release. Mirrors the cc-usage release flow without
# the Sparkle auto-update piece (Game2048 has no appcast).
#
# One-time prerequisites:
#   1. Developer ID Application cert in Keychain (Team XDQ47DMXMK)
#   2. App-specific password for notarization stored as a
#      notarytool keychain profile:
#        xcrun notarytool store-credentials "Game2048Mac" \
#          --apple-id "kyzdes5@gmail.com" \
#          --team-id "XDQ47DMXMK" \
#          --password "<app-specific-password>"
#      (You can reuse another profile via NOTARY_PROFILE=... )
#
# Env overrides:
#   NOTARY_PROFILE   notarytool keychain profile (default Game2048Mac)
#   SKIP_NOTARIZE=1  build + DMG without notarization (dev only)
#   SKIP_SIGN=1      build + DMG without code signing (dev only,
#                    forces SKIP_NOTARIZE=1)
#
# Usage:
#   ./script/release.sh
#───────────────────────────────────────────────────────────

APP_NAME="Game2048Mac"
DISPLAY_NAME="2048 Mac"
BUNDLE_ID="com.manaurum.game2048.mac"
TEAM_ID="XDQ47DMXMK"
SIGN_IDENTITY="Developer ID Application: Viacheslav Kuznetsov (${TEAM_ID})"
NOTARY_PROFILE="${NOTARY_PROFILE:-Game2048Mac}"
SKIP_NOTARIZE="${SKIP_NOTARIZE:-0}"
SKIP_SIGN="${SKIP_SIGN:-0}"

if [ "$SKIP_SIGN" = "1" ]; then
    SKIP_NOTARIZE="1"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_DIR}/build/release"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"
ZIP_PATH="${BUILD_DIR}/${APP_NAME}.zip"

# Read version from project.yml (Mac target uses base settings)
VERSION=$(grep "MARKETING_VERSION" "${PROJECT_DIR}/project.yml" | head -1 | sed 's/.*: *"\(.*\)"/\1/')
BUILD=$(grep "CURRENT_PROJECT_VERSION" "${PROJECT_DIR}/project.yml" | head -1 | sed 's/.*: *"\(.*\)"/\1/')

echo "============================================"
echo "  ${DISPLAY_NAME} v${VERSION} (${BUILD})"
echo "  sign=$([ "$SKIP_SIGN" = "1" ] && echo no || echo yes)  notarize=$([ "$SKIP_NOTARIZE" = "1" ] && echo no || echo yes)"
echo "============================================"
echo ""

#───── Step 1: Regenerate Xcode project ─────
echo "[1/6] Regenerating Xcode project (xcodegen)..."
(cd "$PROJECT_DIR" && xcodegen generate --quiet)

#───── Step 2: Clean & Build Archive ─────
echo "[2/6] Building Release archive..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

ARCHIVE_ARGS=(
    -project "${PROJECT_DIR}/Game2048.xcodeproj"
    -scheme "$APP_NAME"
    -configuration Release
    -destination "generic/platform=macOS"
    -archivePath "$ARCHIVE_PATH"
)

if [ "$SKIP_SIGN" = "1" ]; then
    ARCHIVE_ARGS+=(
        CODE_SIGN_IDENTITY="-"
        CODE_SIGNING_REQUIRED=NO
        CODE_SIGNING_ALLOWED=NO
    )
else
    ARCHIVE_ARGS+=(
        CODE_SIGN_IDENTITY="$SIGN_IDENTITY"
        DEVELOPMENT_TEAM="$TEAM_ID"
        CODE_SIGN_STYLE=Manual
        OTHER_CODE_SIGN_FLAGS="--timestamp --options runtime"
    )
fi

xcodebuild archive "${ARCHIVE_ARGS[@]}" -quiet
echo "   Archive created."

#───── Step 3: Export .app from archive ─────
echo "[3/6] Exporting .app..."

if [ "$SKIP_SIGN" = "1" ]; then
    cat > "${BUILD_DIR}/export.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>manual</string>
</dict>
</plist>
PLIST
else
    cat > "${BUILD_DIR}/export.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Developer ID Application</string>
</dict>
</plist>
PLIST
fi

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "${BUILD_DIR}/export.plist" \
    -exportPath "$BUILD_DIR" \
    -quiet
echo "   App exported: ${APP_PATH}"

#───── Step 4: Notarize app ─────
if [ "$SKIP_NOTARIZE" = "1" ]; then
    echo "[4/6] Skipping notarization (dev mode)."
else
    echo "[4/6] Notarizing .app..."
    ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
    xcrun notarytool submit "$ZIP_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait
    xcrun stapler staple "$APP_PATH"
    echo "   .app notarized and stapled."
fi

#───── Step 5: Create + sign + notarize DMG ─────
echo "[5/6] Creating DMG..."
rm -f "$DMG_PATH"

DMG_STAGING="${BUILD_DIR}/dmg-staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/${DISPLAY_NAME}.app"

# DMG volume icon: reuse the .icns Xcode bakes into the .app
ICNS_PATH="${APP_PATH}/Contents/Resources/AppIcon.icns"

if command -v create-dmg &>/dev/null; then
    CDMG_ARGS=(
        --volname "$DISPLAY_NAME"
        --window-pos 200 120
        --window-size 540 380
        --icon-size 96
        --icon "${DISPLAY_NAME}.app" 140 180
        --app-drop-link 400 180
        --hide-extension "${DISPLAY_NAME}.app"
        --no-internet-enable
    )
    if [ -f "$ICNS_PATH" ]; then
        CDMG_ARGS+=(--volicon "$ICNS_PATH")
    fi
    create-dmg "${CDMG_ARGS[@]}" "$DMG_PATH" "$DMG_STAGING"
else
    echo "   (install 'brew install create-dmg' for styled DMG)"
    ln -s /Applications "$DMG_STAGING/Applications"
    hdiutil create \
        -volname "$DISPLAY_NAME" \
        -srcfolder "$DMG_STAGING" \
        -ov \
        -format UDZO \
        "$DMG_PATH"
fi

rm -rf "$DMG_STAGING"

if [ "$SKIP_SIGN" != "1" ]; then
    codesign --sign "$SIGN_IDENTITY" --timestamp "$DMG_PATH"
fi

if [ "$SKIP_NOTARIZE" != "1" ]; then
    echo "   Notarizing DMG..."
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait
    xcrun stapler staple "$DMG_PATH"
fi

# Re-zip the (now stapled) app for a clean GitHub Release asset
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "   DMG: $DMG_PATH"
echo "   ZIP: $ZIP_PATH"

#───── Step 6: Summary + GitHub release command ─────
ZIP_SIZE=$(stat -f%z "$ZIP_PATH")
DMG_SIZE=$(stat -f%z "$DMG_PATH")
echo ""
echo "[6/6] Artifacts:"
echo "   ZIP: $(du -h "$ZIP_PATH" | cut -f1) ($ZIP_SIZE bytes)"
echo "   DMG: $(du -h "$DMG_PATH" | cut -f1) ($DMG_SIZE bytes)"
echo ""
echo "Next: create GitHub Release"
echo ""
echo "   gh release create v${VERSION} \\"
echo "     '${DMG_PATH}' \\"
echo "     '${ZIP_PATH}' \\"
echo "     --title 'v${VERSION}' \\"
echo "     --notes 'Release notes here'"
echo ""
echo "Done."
