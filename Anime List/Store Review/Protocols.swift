//
//  Protocols.swift
//  Anime List
//
//  Created by Aaron Treinish on 4/5/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import Foundation

enum StorageKey: String {
    case lastVersionPromptedReview
    case dayOfFirstAction
    case actionCount
}

protocol Storage {
    func integer(forKey key: StorageKey) -> Int
    func set(_ value: Int, forKey key: StorageKey)
    func object(forKey key: StorageKey) -> Any?
    func set(_ value: NSDate, forKey key: StorageKey)
    func string(forKey key: StorageKey) -> String?
    func set(_ value: String, forKey key: StorageKey)
}

extension UserDefaults: Storage {
    func integer(forKey key: StorageKey) -> Int {
        return self.integer(forKey: key.rawValue)
    }

    func set(_ value: Int, forKey key: StorageKey) {
        self.set(value, forKey: key.rawValue)
    }

    func object(forKey key: StorageKey) -> Any? {
        return self.object(forKey: key.rawValue)
    }

    func set(_ value: NSDate, forKey key: StorageKey) {
        self.set(value, forKey: key.rawValue)
    }

    func string(forKey key: StorageKey) -> String? {
        return self.string(forKey: key.rawValue)
    }

    func set(_ value: String, forKey key: StorageKey) {
        self.set(value, forKey: key.rawValue)
    }
}

protocol BundleType {
    func object(forInfoDictionaryKey key: String) -> Any?
}

extension Bundle: BundleType {}
