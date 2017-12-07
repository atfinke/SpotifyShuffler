//
//  DeviceResponse.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import Foundation

struct DeviceResponse: Decodable {
    let id: String?
    let is_active: Bool
    let is_restricted: Bool
    let name: String
    let type: String
    let volume_percent: Int?
}
