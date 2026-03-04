# How to Add Items to the macOS Finder Right-Click Menu

## Overview

On modern macOS (Ventura+), the reliable way to add items to Finder's right-click context menu is with **Automator Quick Action workflows** (`.workflow` bundles) installed to `~/Library/Services/`.

**Do NOT use NSServices in Info.plist** — while these register in System Settings, they don't reliably appear in Finder's context menu on modern macOS. They show up inconsistently or only under a nested Services submenu.

## Workflow Bundle Structure

Each action is a `.workflow` bundle with two files:

```
My Action.workflow/
  Contents/
    document.wflow    # The workflow definition (XML plist)
    Info.plist        # Bundle metadata — required for discovery
```

## Info.plist

The `Info.plist` tells macOS this is a service that accepts files:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en_US</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.my-action</string>
    <key>CFBundleName</key>
    <string>My Action</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>My Action</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
            <key>NSSendFileTypes</key>
            <array>
                <string>public.item</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

Key fields:
- `CFBundleIdentifier` — unique reverse-DNS identifier per action
- `CFBundleName` and `NSMenuItem > default` — the label shown in the menu
- `NSMessage` — always `runWorkflowAsService` for Automator workflows
- `NSSendFileTypes` — `public.item` matches all files/folders; use `public.image`, `public.movie`, etc. to restrict

## document.wflow

This is the Automator workflow definition. For a "Run Shell Script" action that receives files as arguments:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>523</string>
    <key>AMApplicationVersion</key>
    <string>2.10</string>
    <key>AMDocumentVersion</key>
    <string>2</string>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Optional</key>
                    <true/>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMBundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
                <key>AMCategory</key>
                <array>
                    <string>AMCategoryUtilities</string>
                </array>
                <key>AMIconName</key>
                <string>RunShellScript</string>
                <key>AMKeyEquivalent</key>
                <dict/>
                <key>AMName</key>
                <string>Run Shell Script</string>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>AMRequiredResources</key>
                <array/>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run Shell Script.action</string>
                <key>ActionName</key>
                <string>Run Shell Script</string>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>YOUR_SHELL_SCRIPT_HERE</string>
                    <key>CheckedForUserDefaultShell</key>
                    <true/>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/bash</string>
                    <key>source</key>
                    <string></string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
                <key>CFBundleVersion</key>
                <string>2.0.3</string>
                <key>CanShowSelectedItemsWhenRun</key>
                <false/>
                <key>CanShowWhenRun</key>
                <true/>
                <key>Category</key>
                <array>
                    <string>AMCategoryUtilities</string>
                </array>
                <key>Class Name</key>
                <string>RunShellScriptAction</string>
                <key>InputUUID</key>
                <string>GENERATE-A-UUID-HERE</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Command</string>
                    <string>Run</string>
                    <string>Unix</string>
                </array>
                <key>OutputUUID</key>
                <string>GENERATE-ANOTHER-UUID-HERE</string>
                <key>UUID</key>
                <string>GENERATE-THIRD-UUID-HERE</string>
            </dict>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>serviceInputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>serviceOutputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>serviceProcessesInput</key>
        <integer>0</integer>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
```

## Key Fields to Customize

### In `ActionParameters`:

- `COMMAND_STRING` — your shell script. Files are passed as `$@` (arguments). Examples:
  - Copy paths to clipboard: `for f in "$@"; do printf '%s\n' "$f"; done | pbcopy`
  - Copy filenames: `for f in "$@"; do basename "$f"; done | pbcopy`
  - Copy parent dirs: `for f in "$@"; do dirname "$f"; done | pbcopy`
  - Open in app: `open -a "My App" "$@"`
- `inputMethod` — `1` = files as arguments (`$@`), `0` = files piped to stdin
- `shell` — `/bin/bash`, `/bin/zsh`, `/usr/bin/python3`, etc.

### In `workflowMetaData`:

- `serviceInputTypeIdentifier`:
  - `com.apple.Automator.fileSystemObject` — files and folders
  - `com.apple.Automator.text` — selected text
  - `com.apple.Automator.nothing` — no input
- `workflowTypeIdentifier` — always `com.apple.Automator.servicesMenu` for right-click actions

### UUIDs:

Generate unique UUIDs for `InputUUID`, `OutputUUID`, and `UUID`. Use `uuidgen` on macOS. Each workflow action needs its own set.

## Installation

```bash
cp -r "My Action.workflow" ~/Library/Services/
/System/Library/CoreServices/pbs -flush
```

The action should appear in Finder's right-click menu immediately after `pbs -flush`. If not:
- Check **System Settings → Keyboard → Keyboard Shortcuts → Services → Files and Folders** and enable it
- Log out and back in as a last resort

## Gotchas

1. **Info.plist is required** — without it, macOS won't discover the workflow for the context menu
2. **pbs -flush** — always run this after installing or updating workflows
3. **No code signing needed** — workflows run as the user, no Gatekeeper issues
4. **Menu item name** — comes from the `.workflow` bundle name (the filename), not from fields inside the plist
5. **Duplicates** — if you also declare NSServices in an app's Info.plist for the same action, you'll get duplicate menu entries. Pick one mechanism.
6. **Quick Actions vs Services** — the "Quick Actions" section in Finder's context menu shows Finder Extensions (a different mechanism). Automator workflows appear directly in the context menu or under a "Services" submenu, depending on macOS version.
