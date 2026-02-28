# Copy Path to Clipboard

A tiny macOS app that copies a file's full path to your clipboard. Use it from Finder's **Right-click > Open With** menu.

No dock icon, no window — it copies the path and quits instantly.

## Install

```bash
./build.sh
cp -r "Copy Path to Clipboard.app" /Applications/
```

Requires Xcode Command Line Tools (`xcode-select --install`).

The build generates the app icon from [`scripts/generate_icon.swift`](/Users/fragmede/projects/mac/copy-path-to-clipboard/scripts/generate_icon.swift), exports the full macOS `AppIcon.iconset`, and packages `Assets/CopyPathToClipboard.icns` into the app bundle.

## Usage

1. Right-click any file or folder in Finder
2. **Open With** > **Copy Path to Clipboard**
3. Paste the full path anywhere

Multiple files selected? All paths are copied, one per line.

## How it works

A minimal Swift/Cocoa app (~20 lines) that:
- Registers as an "Open With" handler for all file types (`public.item`)
- Receives the file URL(s) via Apple Events
- Writes the POSIX path(s) to `NSPasteboard`
- Exits immediately

Runs as `LSUIElement` (no Dock icon, no menu bar).

## License

[MIT](LICENSE)
