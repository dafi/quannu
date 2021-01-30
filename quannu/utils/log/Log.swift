//
//  Log.swift
//  quannu
//
//  Created by davide on 17/01/21.
//

import Foundation

class Log {
    static func info(_ message: String, function: String = #function) {
        NSLog("\(function) \(message)")
    }

    static func error(_ error: Error, function: String = #function) {
        NSLog("\(function) \(error)")
    }
}
