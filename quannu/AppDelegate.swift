//
//  AppDelegate.swift
//  quannu
//
//  Created by davide on 17/01/21.
//

import Cocoa

extension NSStatusBarButton {

    public override func mouseDown(with event: NSEvent) {
        self.highlight(true)
        if let target = self.target,
           let action = self.action {
            _ = target.perform(action, with: self)
        }
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate, InputDelegate {
    private var popover: NSPopover?

    var timer: Timer?
    var statusItem: NSStatusItem!
    var timerSound: TimerSound!
    var isTimerRunning: Bool {
        get {
            if let timer = timer, timer.isValid {
                return true
            }
            return false
        }
    }

    let englishWordMap: TimerInfoWordMap

    override init() {
        englishWordMap = [
            "s": "s",
            "seconds": "s",
            "m": "m",
            "minutes": "m",
            "h": "h",
            "hours": "h",
        ]
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let sound = UserDefaults.standard.soundEffect().soundOrDefault
        sound.volume = UserDefaults.standard.soundVolume()
        timerSound = TimerSound(sound: sound)
        setupStatusBar()
        setupPopover()

        UserDefaults.standard.addObserver(self,
                                          forKeyPath: prefNameSoundEffect,
                                          options: .new,
                                          context: nil)
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: prefNameSoundVolume,
                                          options: .new,
                                          context: nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        UserDefaults.standard.removeObserver(self, forKeyPath: prefNameSoundEffect)
        UserDefaults.standard.removeObserver(self, forKeyPath: prefNameSoundVolume)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case prefNameSoundEffect:
            timerSound.sound = UserDefaults.standard.soundEffect().soundOrDefault
        case prefNameSoundVolume:
            if let value = change?[.newKey] as? NSNumber {
                timerSound.sound.volume = value.floatValue
            }
        default:
            Log.info("Unable to handle \(String(describing: keyPath))")
        }
    }

    func setupStatusBar() {
        let statusbar = NSStatusBar.system
        statusItem = statusbar.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusClicked(_:))

        if let pointSize = statusItem.button?.font?.pointSize {
            statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: pointSize,
                                                                       weight: .regular)
        }

        prepareStatusbar(showTimer: false)
    }

    func setupPopover() {
        let controller = InputViewController()
        controller.delegate = self

        let p = NSPopover()
        p.delegate = self
        p.contentViewController = controller
        p.behavior = .transient
        p.animates = true

        popover = p
    }

    @IBAction func statusClicked(_ sender: NSStatusBarButton) {
        guard let popover = popover else {
            fatalError("Unable to find window.")
        }

        if popover.isShown {
            popover.close()
        } else {
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
        }
    }

    @discardableResult func stopTimer() -> Bool {
        if let timer = timer, timer.isValid {
            timer.invalidate()
            return true
        }
        return false
    }

    func startTimer(pattern: String) throws -> Bool {
        let ti = try TimerInfo.parse(pattern: pattern, specifiersMap: englishWordMap).secondsSinceNow()
        if (ti <= 0) {
            return false
        }
        let fireDate = Int(Date(timeIntervalSinceNow: ti).timeIntervalSince1970)
        timer = schedule(until: fireDate)
        prepareStatusbar(showTimer: true)
        return true
    }

    func schedule(until: Int) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 1,
                                    repeats: true,
                                    block: { self.onFired(timer: $0, fireDate: until)})
    }

    func onFired(timer: Timer, fireDate: Int) {
        let now = Int(Date().timeIntervalSince1970)

        let countdown = self.formatCountdown(seconds: fireDate - now)
        self.statusItem.button?.title = countdown

        if (fireDate <= now) {
            prepareStatusbar(showTimer: false)

            timer.invalidate()
            self.timer = nil
            self.timerSound.play()
            statusItem.button?.fadeAnimation(stop: false)
        }
    }

    func prepareStatusbar(showTimer: Bool) {
        guard let button = statusItem.button else {
            return
        }
        if (showTimer) {
            button.title = "?"
            button.image = nil
        } else {
            button.title = ""
            button.image = NSImage(named: "hourglass")
            button.image!.isTemplate = true
        }
    }

    func formatCountdown(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds - (hours * 3600)) / 60
        let seconds = seconds - (hours * 3600) - (minutes * 60)
        return [hours, minutes, seconds].reduce("") { (str, v) -> String in
            if (str.isEmpty) {
                if (v == 0) {
                    return str
                }
                return "\(v)"
            }
            let digits = v < 10 ? "0\(v)" : "\(v)"
            return "\(str):\(digits)"
        }
    }

    func close() {
        popover?.close()
    }

    func start(text: String) -> Bool {
        do {
            if isTimerRunning {
                if askStopRunningTime() {
                    stop()
                } else {
                    return false
                }
            }
            if try startTimer(pattern: text) {
                close()
                return true
            }
        } catch {
            prepareStatusbar(showTimer: false)
        }
        return false
    }

    private func askStopRunningTime() -> Bool {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Stop running timer?", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Yes", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("No", comment: ""))

        return alert.runModal() == .alertFirstButtonReturn
    }

    func stop() {
        if timerSound.stop() || stopTimer() {
            prepareStatusbar(showTimer: false)
            statusItem.button?.fadeAnimation(stop: true)
        }
    }

    func popoverWillClose(_ notification: Notification) {
        statusItem.button?.highlight(false)
    }

    func popoverWillShow(_ notification: Notification) {
        var isInProgress = timerSound.isPlaying

        if !isInProgress,
           let timer = timer, timer.isValid {
            isInProgress = true
        }
        (popover?.contentViewController as? InputViewController)?.isInProgress = isInProgress
    }

}

