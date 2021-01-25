//
//  Preferences.swift
//  quannu
//
//  Created by davide on 23/01/21.
//

import Cocoa

class PreferencesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate {
    var soundItems = [SoundItem]()
    var sound: NSSound?
    @IBOutlet var soundTable: NSTableView!
    @IBOutlet var removeSoundButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Preferences"

        soundItems = SoundItem.load().sorted(by: <)
        let defaultItem = SoundItem.defaultValue()
        if let row = soundItems.firstIndex(where: { $0 == defaultItem }) {
            soundTable.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            soundTable.scrollRowToVisible(row)
        }
    }

    @IBAction func addSound(_ sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK,
           let url = panel.url {
            if let _ = NSSound(contentsOf: url, byReference: false) {
                soundItems.append(SoundItem(path: url.path, isResource: false))
                soundItems.sort(by: <)
                soundTable.reloadData()
            } else {
                let alert = NSAlert()
                alert.messageText = NSLocalizedString("The file is not a valid sound", comment: "")
                alert.runModal()
            }
        }
    }

    @IBAction func removeSound(_ sender: AnyObject) {
        let row = soundTable.selectedRow

        if row < 0 {
            return
        }
        let item = soundItems[row]

        if item.isResource {
            return
        }

        soundItems.remove(at: row)
        SecureBookmark.shared.removeSecureBookmark(paths: [item.path])

        soundItems[0].setAsDefault()
        soundTable.reloadData()
        soundTable.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        soundTable.scrollRowToVisible(0)
    }

    @IBAction func soundClicked(_ sender: AnyObject) {
        let row = soundTable.selectedRow
        if row < 0 {
            return
        }
        let item = soundItems[row]
        removeSoundButton.isEnabled = !item.isResource

        item.setAsDefault()

        sound?.stop()
        sound = item.sound
        sound?.play()
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
        sound?.stop()
    }

    // MARK: - Table view

    func numberOfRows(in tableView: NSTableView) -> Int {
        return soundItems.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: nil) as! NSTableCellView

        result.textField?.stringValue = soundItems[row].displayName
        return result
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = soundTable.selectedRow
        if row < 0 {
            return
        }
        let item = soundItems[row]
        removeSoundButton.isEnabled = !item.isResource
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
