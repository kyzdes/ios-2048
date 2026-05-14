# Game2048 Mac — Release Guide

Mirrors the cc-usage release flow without Sparkle (Game2048 has no
appcast / auto-update yet).

## Flow

```
script/release.sh ──> GitHub Release (DMG + ZIP)
```

`release.sh` does:

| Step | What |
|------|------|
| 1 | `xcodegen generate` |
| 2 | Build Release archive (universal arm64+x86_64) with Developer ID signature |
| 3 | Export `.app` |
| 4 | Notarize `.app` (notarytool, blocking) and staple |
| 5 | Create styled DMG (create-dmg if available, fallback hdiutil), sign + notarize + staple |
| 6 | Re-zip stapled `.app`, print artifact info + `gh release create` snippet |

## Release checklist

1. Bump version in `project.yml`:
   ```yaml
   MARKETING_VERSION: "1.0.1"
   CURRENT_PROJECT_VERSION: "2"
   ```
2. Run the script:
   ```bash
   ./script/release.sh
   ```
3. Copy the printed `gh release create ...` command and run it.

## Env overrides

| Var | Default | Purpose |
|-----|---------|---------|
| `NOTARY_PROFILE` | `Game2048Mac` | notarytool keychain profile (reuse e.g. `CCUsageViewer` if already configured for same Apple ID/team) |
| `SKIP_NOTARIZE` | `0` | Skip Apple notarization (dev DMG only) |
| `SKIP_SIGN` | `0` | Build unsigned (implies `SKIP_NOTARIZE=1`) |

Dev shortcut for a quick local DMG without signing:
```bash
SKIP_SIGN=1 ./script/release.sh
```

## One-time setup

### Developer ID certificate
- **Developer ID Application: Viacheslav Kuznetsov (XDQ47DMXMK)** in Keychain
- Xcode → Settings → Accounts → Manage Certificates

### notarytool profile
```bash
xcrun notarytool store-credentials "Game2048Mac" \
  --apple-id "kyzdes5@gmail.com" \
  --team-id "XDQ47DMXMK" \
  --password "<app-specific-password>"
```
App-specific password: account.apple.com → Sign-In and Security → App-Specific Passwords.

Already have a profile (e.g. `CCUsageViewer`)? Reuse it:
```bash
NOTARY_PROFILE=CCUsageViewer ./script/release.sh
```

### Optional dependencies
```bash
brew install create-dmg   # styled DMG with arrow/background; otherwise plain hdiutil
brew install xcodegen     # regenerate .xcodeproj from project.yml
```

## Files

| File | Purpose |
|------|---------|
| `script/release.sh` | Full release automation |
| `script/build_and_run.sh` | Quick dev build + run (Debug) |
| `Game2048/Assets.xcassets/AppIcon.appiconset/` | Icon source (iOS 1024 + Mac sizes) |
| `build/release/Game2048Mac.dmg` | Final notarized DMG |
| `build/release/Game2048Mac.zip` | Notarized .app zipped for GitHub asset |

## Troubleshooting

### `No Keychain password item found for profile: Game2048Mac`
Re-run `xcrun notarytool store-credentials "Game2048Mac" ...` or
set `NOTARY_PROFILE` to an existing profile.

### `Unable to open app` on a user's machine
DMG wasn't notarized. `release.sh` notarizes both `.app` and `.dmg` — ask the user to re-download.

### `errSecInternalComponent` during signing
Sign-in to Keychain may be locked. Open Keychain Access and unlock the login keychain, then re-run.
