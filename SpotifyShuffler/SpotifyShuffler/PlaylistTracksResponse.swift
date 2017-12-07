//
//  PlaylistTracksResponse.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import Foundation

struct PlaylistTracksResponse: Decodable {
    let href: URL

    let offset: Int
    let next: URL?
    let previous: URL?

    let total: Int
    let items: [PlaylistItemResponse]
}
