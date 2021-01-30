//
//  View+Animation.swift
//  quannu
//
//  Created by davide on 25/01/21.
//

import Foundation
import Cocoa

extension NSView {
    func fadeAnimation(stop: Bool) {
        self.wantsLayer = true
        guard let viewLayer = self.layer else {
            return
        }
        if (stop) {
            viewLayer.removeAllAnimations()
        } else {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1
            animation.toValue = 0.1
            animation.duration = 1.0
            animation.autoreverses = true
            animation.repeatCount = Float.infinity
            animation.timingFunction = CAMediaTimingFunction(
                name: CAMediaTimingFunctionName.easeInEaseOut)

            viewLayer.add(animation, forKey: nil)
        }
    }
}
