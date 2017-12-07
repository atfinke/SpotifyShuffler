//
//  ContextResponse.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import Foundation

struct ContextResponse: Decodable {
    let type: ObjectTypeResponse
    let uri: String
    let href: URL?
}
