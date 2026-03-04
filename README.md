# Copy Path to Clipboard

Two Finder right-click actions for copying file info to your clipboard:

- **Copy File Name to Clipboard** — copies the full file path (e.g. `/Users/you/Documents/report.pdf`)
- **Copy Path to Clipboard** — copies the containing directory (e.g. `/Users/you/Documents`)

No dock icon, no window — just copies and quits.

## Install

Download the latest release from the [Releases page](https://github.com/fragmede/copy-path-to-clipboard/releases), unzip, and move to `/Applications/`.

The release includes:
- **The app** (signed and notarized) — handles "Open With" for any file type
- **Two Automator Quick Actions** — add "Copy File Name" and "Copy Path" to Finder's right-click menu

### Install Quick Actions

Copy the included `.workflow` files to your Services folder:

```bash
cp -r "Copy Path to Clipboard.workflow" ~/Library/Services/
cp -r "Copy File Name to Clipboard.workflow" ~/Library/Services/
```

> **First-time setup:** The services may need to be enabled in **System Settings → Keyboard → Keyboard Shortcuts → Services → Files and Folders**.

### Build from source

```bash
./build.sh
cp -r "Copy Path to Clipboard.app" /Applications/
```

Requires Xcode Command Line Tools (`xcode-select --install`).

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

1. Right-click any file or folder in Finder
2. Choose **Copy File Name to Clipboard** or **Copy Path to Clipboard**
3. Paste anywhere

Multiple files selected? All values are copied, one per line.

The app also registers as an **Open With** handler. Note that "Open With" triggers Gatekeeper assessment, so files downloaded from the internet may show a warning — the right-click actions don't have this limitation.

## How it works

Two Automator Quick Actions (shell scripts using `pbcopy`) provide the Finder right-click integration. A minimal Swift/Cocoa app handles the "Open With" path.

Runs as `LSUIElement` (no Dock icon, no menu bar).

## License

[MIT](LICENSE)
