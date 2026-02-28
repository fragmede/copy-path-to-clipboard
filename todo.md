# TODO

- [x] Create task tracking files required by repo instructions
- [x] Add a generated macOS app icon source and export all required icon sizes
- [x] Wire the generated `.icns` into the app bundle build
- [x] Document icon generation/build behavior
- [x] Build and verify the app bundle includes the icon assets

## Review

- `./build.sh` completed successfully.
- Verified all required iconset PNG sizes were generated in `Assets/AppIcon.iconset`.
- Verified the built app bundle contains `Contents/Resources/CopyPathToClipboard.icns`.
