//
//  PlaylistItemResponse.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import Foundation

struct PlaylistItemResponse: Decodable {
    let added_at: String
    let track: TrackResponse
}
