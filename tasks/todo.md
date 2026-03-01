# Task Plan

- [x] Create task tracking files required by repo instructions
- [x] Add a generated macOS app icon source and export all required icon sizes
- [x] Wire the generated `.icns` into the app bundle build
- [x] Document icon generation/build behavior
- [x] Build and verify the app bundle includes the icon assets
- [x] Add release automation for signing, notarization, stapling, and packaging
- [x] Build and verify a signed, notarized release artifact
- [ ] Publish the release artifact to GitHub

## Review

- `./build.sh` completed successfully.
- Verified all required iconset PNG sizes were generated in `Assets/AppIcon.iconset`.
- Verified the built app bundle contains `Contents/Resources/CopyPathToClipboard.icns`.
- Added `.gitignore` entries for the built app bundle and Finder metadata.
- `./release.sh` signed the app with `Developer ID Application: samson yeung (8874HJ98MD)`.
- Notarization was accepted via the `notarytool-profile` keychain profile.
- `xcrun stapler validate` succeeded and `spctl -a -vv --type exec` reported `source=Notarized Developer ID`.
