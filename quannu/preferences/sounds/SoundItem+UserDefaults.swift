//
//  SoundItem+UserDefaults.swift
//  quannu
//
//  Created by davide on 25/01/21.
//

import Foundation

extension SoundItem {
    func setAsDefault(forKey key: String = prefNameSoundEffect) {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
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

extension UserDefaults {
    func soundEffect(forKey key: String = prefNameSoundEffect,
                     resourceName: String = SoundItem.resourceName) -> SoundItem {
        if let value = self.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let item = try? decoder.decode(SoundItem.self, from: value) {
                return item
            }
        }
        return SoundItem(path: resourceName, isResource: true)
    }

    func soundVolume(key: String = prefNameSoundVolume, defaultValue: Float = 1) -> Float {
        return (self.object(forKey: key) as? NSNumber)?.floatValue ?? defaultValue
    }

    func setVolume(value: Float, forKey key: String = prefNameSoundVolume) {
        self.setValue(value, forKey: key)
    }
}
