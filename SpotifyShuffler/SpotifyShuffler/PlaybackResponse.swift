//
//  PlaybackResponse.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import Foundation

struct PlaybackResponse: Decodable {

    let timestamp: Int
    let progress_ms: Int?
    
    let is_playing: Bool
    let repeat_state: String
    let shuffle_state: Bool

    let device: DeviceResponse
    let context: ContextResponse?
    let item: TrackResponse?

    var playlistInfo: (userID: String, playlistID: String)? {
        guard let context = context, context.type == .playlist else { return nil }
        let elements = context.uri.components(separatedBy: ":")
        guard elements.count >= 5 else { return nil }
        return (elements[2], elements[4])
    }

}
