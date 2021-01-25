//
//  SoundItem.swift
//  quannu
//
//  Created by davide on 24/01/21.
//

import Foundation
import Cocoa

struct SoundItem : Codable {
    let displayName: String
    let isResource: Bool
    let path: String

    public static let prefName = "sound"
    public static let resourceName = "drizzle"

    init(path: String, isResource: Bool) {
        self.displayName = ((path as NSString).lastPathComponent as NSString).deletingPathExtension.lowercased()
        self.path = path
        self.isResource = isResource
    }

    var sound: NSSound? {
        get {
            if isResource {
                return NSSound(named: displayName)
            }
            let url = SecureBookmark.shared.secureUrlFromBookmark(path: path)
            let sound = NSSound(contentsOfFile: path, byReference: false)
            SecureBookmark.shared.stopAccessingSecurityScopedResource(url: url)
            return sound
        }
    }
}

extension SoundItem : Comparable {
    static func < (lhs: SoundItem, rhs: SoundItem) -> Bool {
        if lhs.isResource != rhs.isResource {
            return lhs.isResource
        }
        return lhs.displayName.caseInsensitiveCompare(rhs.displayName) != .orderedDescending
    }
}

