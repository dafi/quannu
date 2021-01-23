//
//  InputViewController.swift
//  quannu
//
//  Created by davide on 19/01/21.
//

import Cocoa

protocol InputDelegate : AnyObject {
    func close()
    func start(text: String) -> Bool
    func stop()
    func didPreferenceChanged(key: String, value: Any)
}

class InputViewController: NSViewController, NSControlTextEditingDelegate {
    @IBOutlet var inputText: NSTextField!
    @IBOutlet private var state: NSButton!

    weak open var delegate: InputDelegate?

    private var _isInProgress = false
    var isInProgress: Bool {
        get {
            _isInProgress
        }
        set {
            if newValue {
                state.image = NSImage(named: "stop")
            } else {
                state.image = NSImage(named: "play")
            }
            _isInProgress = newValue
        }
    }

    override func awakeFromNib() {
        setupInputText()
    }

    private func setupInputText() {
        inputText.focusRingType = .none
        inputText.backgroundColor = NSColor.clear
        if let color = NSColor(named: "TextPlaceHolder") {
            inputText.setPlaceHolderTextColor(color: color)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func toggle(_ sender: NSButton) {
        if isInProgress {
            delegate?.stop()
            isInProgress = false
        } else {
            if let delegate = delegate,
               delegate.start(text: inputText.stringValue) {
                isInProgress = true
            }
        }
    }

    @IBAction func quit(_ sender: AnyObject) {
        NSApp.terminate(sender)
    }

    @IBAction func preferences(_ sender: AnyObject) {
        // otherwise the panel is not clickable, the only action possible is to click the 'cancel' button
        NSApplication.shared.activate(ignoringOtherApps: true)


        let window = NSWindow(contentViewController: PreferencesViewController())
        window.makeKeyAndOrderFront(nil)


//        let panel = NSOpenPanel()
//        panel.canChooseDirectories = false
//        panel.canChooseFiles = true
//        if panel.runModal() == .OK,
//           let url = panel.url {
//            if let _ = NSSound(contentsOf: url, byReference: false) {
//                delegate?.didPreferenceChanged(key: "sound", value: url)
//            } else {
//                let alert = NSAlert()
//                alert.messageText = NSLocalizedString("The file is not a valid sound", comment: "")
//                alert.runModal()
//            }
//        }
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(cancelOperation):
            if let delegate = delegate {
                delegate.close()
                return true
            }
        case #selector(insertNewline(_:)):
            if let delegate = delegate {
                if delegate.start(text: inputText.stringValue) {
                    isInProgress = true
                }
                return true
            }
        default:
            return false
        }
        return false
    }
    
}
