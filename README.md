# Copy Path to Clipboard

A tiny macOS app that copies a file's full path — or just the file name — to your clipboard from Finder's right-click menu.

No dock icon, no window — it copies and quits instantly.

## Install

Download the latest signed and notarized release from the [Releases page](https://github.com/fragmede/copy-path-to-clipboard/releases), unzip, and move to `/Applications/`.

### Build from source

```bash
./build.sh
cp -r "Copy Path to Clipboard.app" /Applications/
```

Requires Xcode Command Line Tools (`xcode-select --install`).

The build generates the app icon from [`scripts/generate_icon.swift`](scripts/generate_icon.swift), exports the full macOS `AppIcon.iconset`, and packages `Assets/CopyPathToClipboard.icns` into the app bundle.

### Signed Release

To build a signed, notarized, stapled release archive:

```bash
./release.sh
```

This expects:

- A valid `Developer ID Application` certificate in your keychain
- A working `xcrun notarytool` keychain profile (defaults to `notarytool-profile`)

The release script writes a distributable zip to `dist/`.

## Usage

**Option A — Quick Actions / Services menu (recommended)**

1. Right-click any file or folder in Finder
2. **Quick Actions** > **Copy Path to Clipboard** or **Copy File Name to Clipboard**
3. Paste anywhere

This works on all files, including downloads with quarantine attributes that would otherwise trigger a Gatekeeper warning.

> **First-time setup:** Both services must be enabled in **System Settings → Keyboard → Keyboard Shortcuts → Services → Files and Folders** — check the boxes next to "Copy Path to Clipboard" and "Copy File Name to Clipboard". You can also enable them from the Finder context menu under **Quick Actions → Customize...**.

**Option B — Open With**

1. Right-click any file or folder in Finder
2. **Open With** > **Copy Path to Clipboard**
3. Paste the full path anywhere

> **Note:** "Open With" triggers Gatekeeper assessment on the target file. Files downloaded from the internet (with `com.apple.quarantine`) may show a misleading "damaged file" error. Use the Services menu instead for quarantined files.

Multiple files selected? All paths are copied, one per line.

After installing a new build, run `pbs -flush` to refresh the Services menu cache (or log out and back in).

## How it works

A minimal Swift/Cocoa app that:
- Registers as an "Open With" handler for all file types (`public.item`)
- Provides an **NSServices** handler for the Finder Services menu
- Receives file URL(s) via Apple Events (Open With) or pasteboard (Services)
- Writes the POSIX path(s) to `NSPasteboard`
- Exits immediately

Runs as `LSUIElement` (no Dock icon, no menu bar).

## License

[MIT](LICENSE)
