//
//  SoundPanel.swift
//  quannu
//
//  Created by davide on 26/01/21.
//

import Foundation
import Cocoa

class SoundPanel : NSObject, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var table: NSTableView!
    @IBOutlet var removeSoundButton: NSButton!
    @IBOutlet var showInFinderButton: NSButton!
    @IBOutlet var volumeSlider: NSSlider!

    var soundItems = [SoundItem]()
    var sound: NSSound?

    override func awakeFromNib() {
        soundItems = SoundItem.load().sorted(by: <)
        let defaultItem = UserDefaults.standard.soundEffect()
        if let row = soundItems.firstIndex(where: { $0 == defaultItem }) {
            table.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            table.scrollRowToVisible(row)
        }
        sound = defaultItem.sound
        volumeSlider.floatValue = UserDefaults.standard.soundVolume()
        volumeSlider.toolTip = "\(Int(volumeSlider.floatValue * 100))%"
    }

    @IBAction func addSound(_ sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true

        if panel.runModal() == .OK {
            let arr = filterChosen(urls: panel.urls)
            arr.forEach { SecureBookmark.shared.secureBookmark(path: $0.path) }
            soundItems += arr
            soundItems.sort(by: <)
            table.reloadData()
        }
    }

    private func filterChosen(urls: [URL]) -> [SoundItem] {
        return urls
            .filter {
                let path = $0.path
                if soundItems.contains(where: { $0.path == path}) {
                    return false
                }
                return NSSound(contentsOf: $0, byReference: false) != nil
            }
            .map { SoundItem(path: $0.path, isResource: false) }
    }

    @IBAction func removeSound(_ sender: AnyObject) {
        let row = table.selectedRow

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
        table.reloadData()
        table.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        table.scrollRowToVisible(0)
    }

    @IBAction func soundClicked(_ sender: AnyObject) {
        let row = table.selectedRow
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

    @IBAction func onVolumeChange(_ sender: NSSlider) {
        sender.toolTip = "\(Int(sender.floatValue * 100))%"

        UserDefaults.standard.setVolume(value: sender.floatValue)

        if let sound = sound {
            sound.stop()
            sound.volume = sender.floatValue
            sound.play()
        }
    }

    @IBAction func onVolumeMin(_ sender: AnyObject) {
        volumeSlider.floatValue = 0.03
        onVolumeChange(volumeSlider)
    }

    @IBAction func onVolumeMax(_ sender: AnyObject) {
        volumeSlider.floatValue = 1.0
        onVolumeChange(volumeSlider)
    }

    @IBAction func showInFunder(_ sender: AnyObject) {
        let row = table.selectedRow
        if row < 0 {
            return
        }
        let item = soundItems[row]

        let secureUrl = SecureBookmark.shared.secureUrlFromBookmark(path: item.path)
        let urls = [URL(fileURLWithPath: item.path)]

        NSWorkspace.shared.activateFileViewerSelecting(urls)
        SecureBookmark.shared.stopAccessingSecurityScopedResource(url: secureUrl)
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
        let row = table.selectedRow
        if row < 0 {
            return
        }
        let item = soundItems[row]
        removeSoundButton.isEnabled = !item.isResource
        showInFinderButton.isEnabled = !item.isResource
    }
}
