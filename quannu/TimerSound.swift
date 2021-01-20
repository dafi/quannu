//
//  TimerSound.swift
//  quannu
//
//  Created by davide on 19/01/21.
//

import Cocoa

class TimerSound {
    var sound: NSSound
    var isPlaying: Bool {
        get {
            sound.isPlaying
        }
    }

    init(sound: NSSound) {
        self.sound = sound
    }

    func play() {
        sound.loops = true
        sound.play()
    }

    func stop() -> Bool {
        if (sound.isPlaying) {
            sound.stop()
            return true
        }
        return false
    }
    
}
