//
//  SecureBookmark.swift
//  visualdiffer
//
//  Created by davide ficano on 08/08/15.
//  Copyright © 2015 ternaryop.com. All rights reserved.
//

import Foundation

class SecureBookmark {
    private static let SandboxedPaths = "sandboxedPaths"

    public static var shared = { return SecureBookmark() }()

    private init() {}
    
    private static let emptyDictionary = [String: Data]()

    var secureBookmarkDictionary: [String: Data] {
        if let dict = UserDefaults.standard.dictionary(forKey: SecureBookmark.SandboxedPaths) as? [String: Data] {
            return dict
        }
        return SecureBookmark.emptyDictionary
    }

    @discardableResult
    func secureBookmark(path: String, searchClosestPath: Bool = true) -> Bool {
        var bookmark : Data?

        if searchClosestPath {
            if let closestPath = self.findClosestPathTo(path: path, searchPaths:self.secureBookmarkDictionary.keys) {
                bookmark = self.secureBookmarkDictionary[closestPath]
            }
        } else {
            bookmark = self.secureBookmarkDictionary[path]
        }

        if bookmark == nil {
            let url = URL(fileURLWithPath:path)
            do {
                try bookmark = url.bookmarkData(options: .withSecurityScope,
                    includingResourceValuesForKeys:nil,
                    relativeTo:nil)
                var dict = self.secureBookmarkDictionary
                dict[path] = bookmark;
                UserDefaults.standard.set(dict, forKey:SecureBookmark.SandboxedPaths)
                return true
            } catch let error {
                Log.error(error)
            }
        }
        return false
    }

    func secureUrlFromBookmark(path: String, startSecured: Bool = true) -> URL? {
        let dict = self.secureBookmarkDictionary
        guard let bookmarkPath = self.findClosestPathTo(path: path, searchPaths:dict.keys),
            let dataUrl = dict[bookmarkPath] else {
                return nil
        }
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData:dataUrl,
                options:.withSecurityScope,
                relativeTo:nil,
                bookmarkDataIsStale:&isStale)
            if startSecured {
                _ = url.startAccessingSecurityScopedResource()
            }
            return url
        } catch let error {
            Log.error(error)
        }
        return nil
    }

    func stopAccessingSecurityScopedResource(url: URL?) {
        url?.stopAccessingSecurityScopedResource()
    }

    func removeSecureBookmark(paths: [String]) {
        var dict = self.secureBookmarkDictionary
        for path in paths {
            dict.removeValue(forKey: path)
        }
        UserDefaults.standard.set(dict, forKey:SecureBookmark.SandboxedPaths)
    }

    // TODO Find a way to typealias to StringSequence
    func findClosestPathTo<S: Sequence>(path: String, searchPaths: S) -> String? where S.Iterator.Element == String {
        // don't matter if path is a file or a directory, add the separator in any case
        // so hasPrefix works fine with last path component
        // eg "/Users/app 2 3" has prefix "/Users/app 2" but
        // "/Users/app 2 3/" hasn't prefix "/Users/app 2/" and this is the correct result
        let pathWithSep = path.appending("/")
        let sorted = searchPaths.sorted { $0.caseInsensitiveCompare($1) == .orderedDescending }
        for key in sorted {
            if pathWithSep.hasPrefix(key.appending("/")) {
                return key;
            }
        }
        return nil
    }
}
