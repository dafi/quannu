//
//  TimerInfo.swift
//  quannu
//
//  Created by davide on 18/01/21.
//

import Foundation

typealias TimerInfoWordMap = [String: String]

struct TimerInfo {
    private(set) var hours: Int
    private(set) var minutes: Int
    private(set) var seconds: Int
    private(set) var isRelative: Bool

    private static let absoluteTimeRegEx = try! NSRegularExpression(pattern: "^(\\d{1,2})[:.](\\d{1,2})[:.]?(\\d{1,2})?$")
    private static let relativeTimeRegEx = try! NSRegularExpression(pattern: "(\\d+)(?>\\s*)(.)")

    init(hours: Int, minutes: Int, seconds: Int, isRelative: Bool) throws {
        guard 0 <= hours && hours <= 24 else {
            throw TimerInfoError.valueOutOfBound(value: hours)
        }
        guard 0 <= minutes && minutes <= 60 else {
            throw TimerInfoError.valueOutOfBound(value: hours)
        }
        guard 0 <= seconds && seconds <= 60 else {
            throw TimerInfoError.valueOutOfBound(value: hours)
        }
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.isRelative = isRelative
    }

    func secondsSinceNow() -> TimeInterval {
        if (isRelative) {
            return TimeInterval(seconds + minutes * 60 + hours * 3600)
        }
        let now = Date()
        if let date = Calendar(identifier: .gregorian)
            .date(bySettingHour: hours, minute: minutes, second: seconds, of: now) {
            return date.timeIntervalSinceNow
        }
        return 0
    }

    private static func parseAbsoluteTime(pattern: String) throws -> TimerInfo? {
        guard let m = absoluteTimeRegEx.firstMatch(in: pattern,
                                                   options: [],
                                                   range: NSMakeRange(0, pattern.utf16.count)) else {
            return nil
        }
        var seconds: Int = 0
        if let rangeSeconds = Range(m.range(at: 3), in: pattern),
           let value = Int(pattern[rangeSeconds]) {
            seconds = value
        }
        return try TimerInfo(
            hours: Int(pattern[Range(m.range(at: 1), in: pattern)!])!,
            minutes: Int(pattern[Range(m.range(at: 2), in: pattern)!])!,
            seconds: seconds,
            isRelative: false)
    }

    static func parse(pattern: String,
                      specifiersMap: TimerInfoWordMap) throws -> TimerInfo {
        let patternLower = pattern.lowercased()

        if let ti = try parseAbsoluteTime(pattern: patternLower) {
            return ti
        }
        return try parseRelativeTime(pattern: patternLower, specifiersMap: specifiersMap)
    }

    private static func parseRelativeTime(pattern: String,
                                          specifiersMap: TimerInfoWordMap) throws -> TimerInfo {
        var timerInfo = try TimerInfo(hours: 0, minutes: 0, seconds: 0, isRelative: true)
        try relativeTimeRegEx.matches(in: pattern, options: [], range: NSMakeRange(0, pattern.utf16.count)).forEach {
            let specifierPattern = String(pattern[Range($0.range(at: 2), in: pattern)!])
            guard let amount = Int(pattern[Range($0.range(at: 1), in: pattern)!]),
                  let specifier = specifiersMap[specifierPattern] else {
                throw TimerInfoError.invalid(specifier: specifierPattern)
            }
            try timerInfo.increment(specifier: specifier, amount: amount)
        }
        return timerInfo;
    }

    private mutating func increment(specifier: String, amount: Int) throws {
        switch specifier {
        case "s":
            seconds += amount
        case "m":
            minutes += amount
        case "h":
            hours += amount
        default:
            throw TimerInfoError.invalid(specifier: specifier)
        }
    }
}

enum TimerInfoError: Error {
    case valueOutOfBound(value: Int)
    case invalidExpression
    case invalid(specifier: String)
}

