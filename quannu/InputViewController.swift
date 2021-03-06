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
}

class InputViewController: NSViewController, NSControlTextEditingDelegate {
    @IBOutlet var inputText: NSTextField!
    @IBOutlet private var state: NSButton!

    weak open var delegate: InputDelegate?
    weak var preferences: PreferencesViewController?

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

    @IBAction func about(_ sender: AnyObject) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @IBAction func openSupport(_ sender: AnyObject) {
        if let url = URL(string: "https://github.com/dafi/quannu") {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func preferences(_ sender: AnyObject) {
        if let window = preferences?.view.window {
            NSApplication.shared.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        } else {
            preferences = PreferencesViewController.openWindow()
        }
    }

    override func cancelOperation(_ sender: Any?) {
        delegate?.close()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
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
