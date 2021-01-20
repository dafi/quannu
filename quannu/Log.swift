//
//  Log.swift
//  quannu
//
//  Created by davide on 17/01/21.
//

import Foundation

class Log {
    static func log(_ message: String, function: String = #function) {
        NSLog("\(function) \(message)")
    }

    static func logError(_ error: Error, function: String = #function) {
        NSLog("\(function) \(error)")
    }
}
