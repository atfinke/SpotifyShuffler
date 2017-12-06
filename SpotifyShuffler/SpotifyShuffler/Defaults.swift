//
//  Defaults.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import Foundation

class Defaults {

    // MARK: - Types

    enum Key: String {
        case keepPlaying, alwaysOpen
    }
    
    // MARK: - Helpers

    static func value<T: Any>(for key: Key) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }

    static func set(_ value: Any, for key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

}
