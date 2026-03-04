import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        let paths = urls.map { $0.path }.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(paths, forType: .string)
        NSApplication.shared.terminate(nil)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.servicesProvider = self
        // If launched without files, quit after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NSApplication.shared.terminate(nil)
        }
    }

    @objc func copyPathService(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        guard let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else { return }
        let paths = urls.map { $0.path }.joined(separator: "\n")
        copyToClipboardAndQuit(paths)
    }

    @objc func copyFileNameService(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        guard let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else { return }
        let names = urls.map { $0.lastPathComponent }.joined(separator: "\n")
        copyToClipboardAndQuit(names)
    }

    private func copyToClipboardAndQuit(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        // Don't terminate immediately — services require the app to stay alive briefly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApplication.shared.terminate(nil)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
