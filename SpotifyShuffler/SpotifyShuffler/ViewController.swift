//
//  ViewController.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit
import GameplayKit

enum ObjectTypeResponse: String, Decodable {
    case album, artist, playlist
}

struct PlaylistItemTrackResponse: Decodable {
    let id: String
    let name: String
    let uri: String
}

struct PlaylistItemResponse: Decodable {
    let added_at: String
    let track: PlaylistItemTrackResponse
}

struct PlaylistResponse: Decodable {
    let href: URL

    let offset: Int
    let next: URL?
    let previous: URL?

    let total: Int
    let items: [PlaylistItemResponse]
}

struct PlaybackContextResponse: Decodable {
    let type: ObjectTypeResponse
    let uri: String
    let href: URL?
}

struct PlaybackResponse: Decodable {
    let is_playing: Bool
    let progress_ms: Int?
    let context: PlaybackContextResponse?
    let item: PlaylistItemTrackResponse?

    var playlistID: String? {
        guard let context = context, context.type == .playlist else { return nil }
        return context.uri.components(separatedBy: ":").last
    }
}

struct SpotifyManager {

    private var authenticatedUserID: String?
    private let decoder = JSONDecoder()


    func fetchPlaybackInfo() {
        guard let url = URL(string: "https://api.spotify.com/v1/me/player") else {
            fatalError()
        }

        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if let error = error {

            } else if let data = data,
                let response = try? self.decoder.decode(PlaybackResponse.self, from: data) {

            }

        }
    }

    func fetchPlaylistInfo(for playlistID: String) {
        guard let userID = authenticatedUserID,
            let url = URL(string: "https://api.spotify.com/v1/users/\(userID)/playlists/\(playlistID)/tracks") else {
            fatalError()
        }

        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if let error = error {

            } else if let data = data,
                let response = try? self.decoder.decode(PlaylistResponse.self, from: data) {




            }

        }
    }

//    func createNewPlaylist(from)

}

class ViewController: UIViewController {

    // MARK: - Now Playing Labels

    @IBOutlet weak var nowPlayingTitleLabel: UILabel!
    @IBOutlet weak var nowPlayingLabel: UILabel!

    // MARK: - Main Button

    @IBOutlet weak var button: UIButton!

    // MARK: - Option Outlets

    @IBOutlet weak var keepPlayingSwitch: UISwitch!
    @IBOutlet weak var keepPlayingTitleLabel: UILabel!
    @IBOutlet weak var openSwitch: UISwitch!
    @IBOutlet weak var openSpotifyTitleLabel: UILabel!

    // MARK: - Properties

    private var isAuthenticated = false

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()

        let data = currentJSON.data(using: .utf8)!
        let bla = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0))

        let aaa = try! JSONDecoder().decode(PlaybackResponse.self, from: data)
        print(aaa)
        print()
        print(aaa.playlistID)
    }



    func setupInterface() {
        button.layer.cornerRadius = button.frame.width / 2

        keepPlayingSwitch.isOn = Defaults.value(for: .keepPlaying) ?? false
        openSwitch.isOn = Defaults.value(for: .alwaysOpen) ?? false
    }

    func sdfsdf() {
        let arr = [1,2,3,4]
        GKRandomSource.sharedRandom().arrayByShufflingObjects(in: arr)
        let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: arr)

        (arr as NSArray).shuffled()
    }

    // MARK: - Actions

    @IBAction func buttonPressed(_ sender: Any) {
    }

    @IBAction func keepPlayingSwitchFlipped(_ sender: Any) {
        Defaults.set(keepPlayingSwitch.isOn, for: .keepPlaying)
    }

    @IBAction func openSwitchFlipped(_ sender: Any) {
        Defaults.set(openSwitch.isOn, for: .alwaysOpen)
    }

}

let currentJSON = """
{
  "timestamp" : 1512589785412,
  "progress_ms" : 7151,
  "is_playing" : true,
  "item" : {
    "album" : {
      "album_type" : "album",
      "artists" : [ {
        "external_urls" : {
          "spotify" : "https://open.spotify.com/artist/4njdEjTnLfcGImKZu1iSrz"
        },
        "href" : "https://api.spotify.com/v1/artists/4njdEjTnLfcGImKZu1iSrz",
        "id" : "4njdEjTnLfcGImKZu1iSrz",
        "name" : "AWOLNATION",
        "type" : "artist",
        "uri" : "spotify:artist:4njdEjTnLfcGImKZu1iSrz"
      } ],
      "available_markets" : [ ],
      "external_urls" : {
        "spotify" : "https://open.spotify.com/album/1fag8cnc5p4Umu4tRMAsLv"
      },
      "href" : "https://api.spotify.com/v1/albums/1fag8cnc5p4Umu4tRMAsLv",
      "id" : "1fag8cnc5p4Umu4tRMAsLv",
      "images" : [ {
        "height" : 640,
        "url" : "https://i.scdn.co/image/367655fc10c5d08653e8080696e7c630fb8cd8ee",
        "width" : 640
      }, {
        "height" : 300,
        "url" : "https://i.scdn.co/image/51f8e46b1bae23be8e3aeb34ff615449a6cf3012",
        "width" : 300
      }, {
        "height" : 64,
        "url" : "https://i.scdn.co/image/6c68ddce9da55e3b099d9cee1f6d9c333832def0",
        "width" : 64
      } ],
      "name" : "Megalithic Symphony",
      "type" : "album",
      "uri" : "spotify:album:1fag8cnc5p4Umu4tRMAsLv"
    },
    "artists" : [ {
      "external_urls" : {
        "spotify" : "https://open.spotify.com/artist/4njdEjTnLfcGImKZu1iSrz"
      },
      "href" : "https://api.spotify.com/v1/artists/4njdEjTnLfcGImKZu1iSrz",
      "id" : "4njdEjTnLfcGImKZu1iSrz",
      "name" : "AWOLNATION",
      "type" : "artist",
      "uri" : "spotify:artist:4njdEjTnLfcGImKZu1iSrz"
    } ],
    "available_markets" : [ ],
    "disc_number" : 1,
    "duration_ms" : 178840,
    "explicit" : false,
    "external_ids" : {
      "isrc" : "USP6L1000065"
    },
    "external_urls" : {
      "spotify" : "https://open.spotify.com/track/7LJF6AtijSniUJpmZTqKRj"
    },
    "href" : "https://api.spotify.com/v1/tracks/7LJF6AtijSniUJpmZTqKRj",
    "id" : "7LJF6AtijSniUJpmZTqKRj",
    "name" : "Kill Your Heroes",
    "popularity" : 2,
    "preview_url" : null,
    "track_number" : 8,
    "type" : "track",
    "uri" : "spotify:track:7LJF6AtijSniUJpmZTqKRj"
  },
  "context" : {
    "external_urls" : {
      "spotify" : "https://open.spotify.com/user/j3d1_warr10r/playlist/7KNx0qPbflHeT7UHYnx34O"
    },
    "href" : "https://api.spotify.com/v1/users/j3d1_warr10r/playlists/7KNx0qPbflHeT7UHYnx34O",
    "type" : "playlist",
    "uri" : "spotify:user:j3d1_warr10r:playlist:7KNx0qPbflHeT7UHYnx34O"
  },
  "device" : {
    "id" : "d2ad65ccdda78e405f9d70da3271b93c16fb2c42",
    "is_active" : true,
    "is_restricted" : false,
    "name" : "A.MB",
    "type" : "Computer",
    "volume_percent" : 66
  },
  "repeat_state" : "off",
  "shuffle_state" : true
}
"""

let playlistJSON = """
{
"href" : "https://api.spotify.com/v1/users/j3d1_warr10r/playlists/7IyZ1UZoohWNKQyVO5owIy/tracks?offset=0&limit=5",
"items" : [ {
"added_at" : "2017-05-09T18:01:19Z",
"added_by" : {
"external_urls" : {
"spotify" : "http://open.spotify.com/user/j3d1_warr10r"
},
"href" : "https://api.spotify.com/v1/users/j3d1_warr10r",
"id" : "j3d1_warr10r",
"type" : "user",
"uri" : "spotify:user:j3d1_warr10r"
},
"is_local" : false,
"track" : {
"album" : {
"album_type" : "single",
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/2JSc53B5cQ31m0xTB7JFpG"
},
"href" : "https://api.spotify.com/v1/artists/2JSc53B5cQ31m0xTB7JFpG",
"id" : "2JSc53B5cQ31m0xTB7JFpG",
"name" : "Rogue Wave",
"type" : "artist",
"uri" : "spotify:artist:2JSc53B5cQ31m0xTB7JFpG"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"external_urls" : {
"spotify" : "https://open.spotify.com/album/0ipi3dQXxde567orrSLq50"
},
"href" : "https://api.spotify.com/v1/albums/0ipi3dQXxde567orrSLq50",
"id" : "0ipi3dQXxde567orrSLq50",
"images" : [ {
"height" : 640,
"url" : "https://i.scdn.co/image/68603b4918d2fdc73ea5855059f2528be3479353",
"width" : 438
}, {
"height" : 300,
"url" : "https://i.scdn.co/image/7ab634e11ea7418f731b922222210c80980e8429",
"width" : 205
}, {
"height" : 64,
"url" : "https://i.scdn.co/image/38f9f19f9a55ca0e81eab614905a45366ca7ffa1",
"width" : 44
} ],
"name" : "Eyes",
"type" : "album",
"uri" : "spotify:album:0ipi3dQXxde567orrSLq50"
},
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/2JSc53B5cQ31m0xTB7JFpG"
},
"href" : "https://api.spotify.com/v1/artists/2JSc53B5cQ31m0xTB7JFpG",
"id" : "2JSc53B5cQ31m0xTB7JFpG",
"name" : "Rogue Wave",
"type" : "artist",
"uri" : "spotify:artist:2JSc53B5cQ31m0xTB7JFpG"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"disc_number" : 1,
"duration_ms" : 148866,
"explicit" : false,
"external_ids" : {
"isrc" : "USSUB0671301"
},
"external_urls" : {
"spotify" : "https://open.spotify.com/track/7fArBkBSsaUF5mOcpTL56I"
},
"href" : "https://api.spotify.com/v1/tracks/7fArBkBSsaUF5mOcpTL56I",
"id" : "7fArBkBSsaUF5mOcpTL56I",
"name" : "Eyes",
"popularity" : 59,
"preview_url" : "https://p.scdn.co/mp3-preview/1fe6d7799c30e6b2bfbe87c8e584ae3a982f1ad5?cid=8897482848704f2a8f8d7c79726a70d4",
"track_number" : 1,
"type" : "track",
"uri" : "spotify:track:7fArBkBSsaUF5mOcpTL56I"
}
}, {
"added_at" : "2017-05-09T18:01:19Z",
"added_by" : {
"external_urls" : {
"spotify" : "http://open.spotify.com/user/j3d1_warr10r"
},
"href" : "https://api.spotify.com/v1/users/j3d1_warr10r",
"id" : "j3d1_warr10r",
"type" : "user",
"uri" : "spotify:user:j3d1_warr10r"
},
"is_local" : false,
"track" : {
"album" : {
"album_type" : "single",
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/3WOOglGBDGvr6c2WBeMAWn"
},
"href" : "https://api.spotify.com/v1/artists/3WOOglGBDGvr6c2WBeMAWn",
"id" : "3WOOglGBDGvr6c2WBeMAWn",
"name" : "Urban Cone",
"type" : "artist",
"uri" : "spotify:artist:3WOOglGBDGvr6c2WBeMAWn"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"external_urls" : {
"spotify" : "https://open.spotify.com/album/78dYXxV5DUwNIbopS1Zon9"
},
"href" : "https://api.spotify.com/v1/albums/78dYXxV5DUwNIbopS1Zon9",
"id" : "78dYXxV5DUwNIbopS1Zon9",
"images" : [ {
"height" : 640,
"url" : "https://i.scdn.co/image/15f10fa90ce6f80e22e1ea89712ab682a432ccb6",
"width" : 640
}, {
"height" : 300,
"url" : "https://i.scdn.co/image/df6112230afcbb40bbce924f205527fdef65dc00",
"width" : 300
}, {
"height" : 64,
"url" : "https://i.scdn.co/image/42910534e0946ddfef92be12ad5aeb01f08b61a0",
"width" : 64
} ],
"name" : "Weekends",
"type" : "album",
"uri" : "spotify:album:78dYXxV5DUwNIbopS1Zon9"
},
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/3WOOglGBDGvr6c2WBeMAWn"
},
"href" : "https://api.spotify.com/v1/artists/3WOOglGBDGvr6c2WBeMAWn",
"id" : "3WOOglGBDGvr6c2WBeMAWn",
"name" : "Urban Cone",
"type" : "artist",
"uri" : "spotify:artist:3WOOglGBDGvr6c2WBeMAWn"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"disc_number" : 1,
"duration_ms" : 206306,
"explicit" : false,
"external_ids" : {
"isrc" : "SEUM71500755"
},
"external_urls" : {
"spotify" : "https://open.spotify.com/track/5Cw9Q9Mz28xTv5ajClVi23"
},
"href" : "https://api.spotify.com/v1/tracks/5Cw9Q9Mz28xTv5ajClVi23",
"id" : "5Cw9Q9Mz28xTv5ajClVi23",
"name" : "Weekends - Radio Edit",
"popularity" : 10,
"preview_url" : "https://p.scdn.co/mp3-preview/7be3bd7b32217b99b9960f5299adc8300cac0905?cid=8897482848704f2a8f8d7c79726a70d4",
"track_number" : 2,
"type" : "track",
"uri" : "spotify:track:5Cw9Q9Mz28xTv5ajClVi23"
}
}, {
"added_at" : "2017-05-09T18:01:19Z",
"added_by" : {
"external_urls" : {
"spotify" : "http://open.spotify.com/user/j3d1_warr10r"
},
"href" : "https://api.spotify.com/v1/users/j3d1_warr10r",
"id" : "j3d1_warr10r",
"type" : "user",
"uri" : "spotify:user:j3d1_warr10r"
},
"is_local" : false,
"track" : {
"album" : {
"album_type" : "album",
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/5DK8eK7fjvRsziXzyr3sFA"
},
"href" : "https://api.spotify.com/v1/artists/5DK8eK7fjvRsziXzyr3sFA",
"id" : "5DK8eK7fjvRsziXzyr3sFA",
"name" : "Moon Taxi",
"type" : "artist",
"uri" : "spotify:artist:5DK8eK7fjvRsziXzyr3sFA"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"external_urls" : {
"spotify" : "https://open.spotify.com/album/5hqGibvfAVIp9plqmnflCg"
},
"href" : "https://api.spotify.com/v1/albums/5hqGibvfAVIp9plqmnflCg",
"id" : "5hqGibvfAVIp9plqmnflCg",
"images" : [ {
"height" : 640,
"url" : "https://i.scdn.co/image/cae487a8337ad5b19b74fb4af0b28bf5146d9174",
"width" : 640
}, {
"height" : 300,
"url" : "https://i.scdn.co/image/690cf9db5b3d29fb15009542240724e7804db3d8",
"width" : 300
}, {
"height" : 64,
"url" : "https://i.scdn.co/image/41cc76a3e4f1d4153f4f836e884ed259cdd5f5c9",
"width" : 64
} ],
"name" : "Daybreaker",
"type" : "album",
"uri" : "spotify:album:5hqGibvfAVIp9plqmnflCg"
},
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/5DK8eK7fjvRsziXzyr3sFA"
},
"href" : "https://api.spotify.com/v1/artists/5DK8eK7fjvRsziXzyr3sFA",
"id" : "5DK8eK7fjvRsziXzyr3sFA",
"name" : "Moon Taxi",
"type" : "artist",
"uri" : "spotify:artist:5DK8eK7fjvRsziXzyr3sFA"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"disc_number" : 1,
"duration_ms" : 201133,
"explicit" : false,
"external_ids" : {
"isrc" : "QMRSZ1501133"
},
"external_urls" : {
"spotify" : "https://open.spotify.com/track/6TmUM3aMNJqC47QSbH61bN"
},
"href" : "https://api.spotify.com/v1/tracks/6TmUM3aMNJqC47QSbH61bN",
"id" : "6TmUM3aMNJqC47QSbH61bN",
"name" : "Run Right Back",
"popularity" : 52,
"preview_url" : "https://p.scdn.co/mp3-preview/0c92183819db3a6233daf4fe55f4860445f6128e?cid=8897482848704f2a8f8d7c79726a70d4",
"track_number" : 3,
"type" : "track",
"uri" : "spotify:track:6TmUM3aMNJqC47QSbH61bN"
}
}, {
"added_at" : "2017-05-09T18:01:19Z",
"added_by" : {
"external_urls" : {
"spotify" : "http://open.spotify.com/user/j3d1_warr10r"
},
"href" : "https://api.spotify.com/v1/users/j3d1_warr10r",
"id" : "j3d1_warr10r",
"type" : "user",
"uri" : "spotify:user:j3d1_warr10r"
},
"is_local" : false,
"track" : {
"album" : {
"album_type" : "album",
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/3RthMq3xfDQZl80cMEg1JQ"
},
"href" : "https://api.spotify.com/v1/artists/3RthMq3xfDQZl80cMEg1JQ",
"id" : "3RthMq3xfDQZl80cMEg1JQ",
"name" : "Finish Ticket",
"type" : "artist",
"uri" : "spotify:artist:3RthMq3xfDQZl80cMEg1JQ"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"external_urls" : {
"spotify" : "https://open.spotify.com/album/1yz3tI7TG1fpTIzBzW1mud"
},
"href" : "https://api.spotify.com/v1/albums/1yz3tI7TG1fpTIzBzW1mud",
"id" : "1yz3tI7TG1fpTIzBzW1mud",
"images" : [ {
"height" : 640,
"url" : "https://i.scdn.co/image/e6d9f8cc40d24f599e5f26ec3fd5ef0f76cd0061",
"width" : 640
}, {
"height" : 300,
"url" : "https://i.scdn.co/image/1bb97c361f1e94062b4f621c46f5b51345867cbf",
"width" : 300
}, {
"height" : 64,
"url" : "https://i.scdn.co/image/02630c59c182c8fe1c239b26fe320d693fe3aa92",
"width" : 64
} ],
"name" : "When Night Becomes Day",
"type" : "album",
"uri" : "spotify:album:1yz3tI7TG1fpTIzBzW1mud"
},
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/3RthMq3xfDQZl80cMEg1JQ"
},
"href" : "https://api.spotify.com/v1/artists/3RthMq3xfDQZl80cMEg1JQ",
"id" : "3RthMq3xfDQZl80cMEg1JQ",
"name" : "Finish Ticket",
"type" : "artist",
"uri" : "spotify:artist:3RthMq3xfDQZl80cMEg1JQ"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"disc_number" : 1,
"duration_ms" : 210866,
"explicit" : false,
"external_ids" : {
"isrc" : "USAT21502539"
},
"external_urls" : {
"spotify" : "https://open.spotify.com/track/40xxCI61nOsrtfoiiNGBl4"
},
"href" : "https://api.spotify.com/v1/tracks/40xxCI61nOsrtfoiiNGBl4",
"id" : "40xxCI61nOsrtfoiiNGBl4",
"name" : "Scavenger",
"popularity" : 39,
"preview_url" : "https://p.scdn.co/mp3-preview/f15c0e49e01a487f4a4d9db1df89614a8fdba2cf?cid=8897482848704f2a8f8d7c79726a70d4",
"track_number" : 1,
"type" : "track",
"uri" : "spotify:track:40xxCI61nOsrtfoiiNGBl4"
}
}, {
"added_at" : "2017-05-09T18:01:19Z",
"added_by" : {
"external_urls" : {
"spotify" : "http://open.spotify.com/user/j3d1_warr10r"
},
"href" : "https://api.spotify.com/v1/users/j3d1_warr10r",
"id" : "j3d1_warr10r",
"type" : "user",
"uri" : "spotify:user:j3d1_warr10r"
},
"is_local" : false,
"track" : {
"album" : {
"album_type" : "album",
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/4Om4kO491KUeVkwTLiVQq3"
},
"href" : "https://api.spotify.com/v1/artists/4Om4kO491KUeVkwTLiVQq3",
"id" : "4Om4kO491KUeVkwTLiVQq3",
"name" : "Dresses",
"type" : "artist",
"uri" : "spotify:artist:4Om4kO491KUeVkwTLiVQq3"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"external_urls" : {
"spotify" : "https://open.spotify.com/album/1tWU86dOXqIE0oSDBg70lm"
},
"href" : "https://api.spotify.com/v1/albums/1tWU86dOXqIE0oSDBg70lm",
"id" : "1tWU86dOXqIE0oSDBg70lm",
"images" : [ {
"height" : 640,
"url" : "https://i.scdn.co/image/1fd50fe5bf27de6786438296af705349a25dca46",
"width" : 640
}, {
"height" : 300,
"url" : "https://i.scdn.co/image/62c054306a4f589e1b433a4d1c78566b677c2880",
"width" : 300
}, {
"height" : 64,
"url" : "https://i.scdn.co/image/06cb42e4957aa2b72e24ea441fbca367635a6546",
"width" : 64
} ],
"name" : "Let Down",
"type" : "album",
"uri" : "spotify:album:1tWU86dOXqIE0oSDBg70lm"
},
"artists" : [ {
"external_urls" : {
"spotify" : "https://open.spotify.com/artist/4Om4kO491KUeVkwTLiVQq3"
},
"href" : "https://api.spotify.com/v1/artists/4Om4kO491KUeVkwTLiVQq3",
"id" : "4Om4kO491KUeVkwTLiVQq3",
"name" : "Dresses",
"type" : "artist",
"uri" : "spotify:artist:4Om4kO491KUeVkwTLiVQq3"
} ],
"available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TH", "TR", "TW", "US", "UY", "VN" ],
"disc_number" : 1,
"duration_ms" : 231120,
"explicit" : false,
"external_ids" : {
"isrc" : "US4K31500068"
},
"external_urls" : {
"spotify" : "https://open.spotify.com/track/7dsHYU5bH0qksf8e1loXcl"
},
"href" : "https://api.spotify.com/v1/tracks/7dsHYU5bH0qksf8e1loXcl",
"id" : "7dsHYU5bH0qksf8e1loXcl",
"name" : "Catch",
"popularity" : 48,
"preview_url" : "https://p.scdn.co/mp3-preview/c1bfc56e7eed581f0a54c11855897757863b4b92?cid=8897482848704f2a8f8d7c79726a70d4",
"track_number" : 1,
"type" : "track",
"uri" : "spotify:track:7dsHYU5bH0qksf8e1loXcl"
}
} ],
"limit" : 5,
"next" : "https://api.spotify.com/v1/users/j3d1_warr10r/playlists/7IyZ1UZoohWNKQyVO5owIy/tracks?offset=5&limit=5",
"offset" : 0,
"previous" : null,
"total" : 354
}
"""
