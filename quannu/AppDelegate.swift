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
    var timerSound: TimerSound

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

        timerSound = TimerSound(sound: NSSound(named: "drizzle")!)
    }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusBar()
        setupPopover()
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
            if try startTimer(pattern: text) {
                close()
                return true
            }
        } catch {
            prepareStatusbar(showTimer: false)
        }
        return false
    }

    func stop() {
        if timerSound.stop() || stopTimer() {
            prepareStatusbar(showTimer: false)
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

