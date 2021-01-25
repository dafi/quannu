//
//  SoundItem+UserDefaults.swift
//  quannu
//
//  Created by davide on 25/01/21.
//

import Foundation

extension SoundItem {
    func setAsDefault(key: String = prefName) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: key)
            SecureBookmark.shared.secureBookmark(path: path)
        }
    }

    static func defaultValue(key: String = prefName,
                             defaultResourceName: String = resourceName) -> SoundItem {
        if let value = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let item = try? decoder.decode(SoundItem.self, from: value) {
                return item
            }
        }
        return SoundItem(path: defaultResourceName, isResource: true)
    }

    static func load() -> [SoundItem] {
        var items : [SoundItem] = Bundle.main.paths(forResourcesOfType: "m4a", inDirectory: nil).map {
            return SoundItem(path: $0, isResource: true)
        }

        for path in SecureBookmark.shared.secureBookmarkDictionary.keys {
            items.append(SoundItem(path: path, isResource: false))
        }

        return items
    }
}
