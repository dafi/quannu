//
//  Preferences.swift
//  quannu
//
//  Created by davide on 23/01/21.
//

import Cocoa

class PreferencesViewController: NSViewController, NSWindowDelegate {
    @IBOutlet var soundsPanel: SoundPanel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Preferences"
    }

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers! {
            case "w":
                view.window?.close()
            default:
                break
            }
        }
    }

    // MARK: - Window

    func windowWillClose(_ notification: Notification) {
        soundsPanel.sound?.stop()
    }

}

extension PreferencesViewController {
    @discardableResult
    static func openWindow() -> PreferencesViewController {
        let c = PreferencesViewController()
        let window = NSWindow(contentViewController: c)
        window.styleMask = [.titled, .closable]
        window.delegate = c

        window.makeKeyAndOrderFront(nil)

        // otherwise the panel is not clickable, the only action possible is to click the 'cancel' button
        NSApplication.shared.activate(ignoringOtherApps: true)

        return c
    }
}
