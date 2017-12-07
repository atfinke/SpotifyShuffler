//
//  PlaylistResponse.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import Foundation

struct PlaylistResponse: Decodable {
    let id: String
    let name: String
    let description: String?
}
