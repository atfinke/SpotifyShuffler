//
//  SpotifyManager.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import Foundation
import GameplayKit
import SafariServices

class SpotifyManager: NSObject, SFSafariViewControllerDelegate {

    // MARK: - Type

    enum SpotifyManagerError: Error {
        case authentication, response, network
    }

    // MARK: - Properties

    static let shared = SpotifyManager()

    private let auth = SPTAuth()
    private var session: SPTSession?
    private var sessionUserID: String?
    private let decoder = JSONDecoder()

    var isAuthenticated: Bool {
        return session != nil && sessionUserID != nil
    }

    // MARK: - Initialization


    func updateSession() {
        print("SpotifyManager: " + #function)
        let sessionData: Data? = Defaults.value(for: .session)
        let userID: String? = Defaults.value(for: .userID)

        guard let data = sessionData,
            let sessionUserID = userID,
            let session = NSKeyedUnarchiver.unarchiveObject(with: data) as? SPTSession else {
                return
        }

        if session.isValid() {
            print("SpotifyManager: " + #function + " Valid Session")
            self.session = session
            self.sessionUserID = sessionUserID
        } else {
            print("SpotifyManager: " + #function + " Invalid Session")
            auth.renewSession(session, callback: { error, renewedSession in
                if let error = error {
                    print("SpotifyManager: " + #function + " Renew session error: \(error)")
                } else if let session = renewedSession {
                    print("SpotifyManager: " + #function + " Renewed session")
                    self.session = session
                }
            })
            fetchProfile(completion: { (response, error) in
                if let error = error {
                    print("SpotifyManager: " + #function + " Profile error: \(error)")
                } else if let response = response {
                    print("SpotifyManager: " + #function + " Fetched Profile")
                    self.sessionUserID = response.id
                    Defaults.set(response.id, for: .userID)
                }
            })
        }
    }

    // MARK: - Helpers

    func fetchPlaylistName(completion: @escaping (_ title: String?, _ error: SpotifyManagerError?) -> ()) {
        print("SpotifyManager: " + #function)
        fetchPlayback { (response, error) in
            if let error = error {
                print("SpotifyManager: " + #function + " error: \(error)")
                completion(nil, error)
            } else if let response = response, let playlistInfo = response.playlistInfo {
                print("SpotifyManager: " + #function + " got response")
                self.fetchPlaylist(info: playlistInfo, completion: { (response, error) in
                    completion(response?.name, error)
                })
            } else {
                print("SpotifyManager: " + #function + " response error")
                completion(nil, .response)
            }
        }
    }

    func createShuffledPlaylist(overwrite: Bool) {
        var error: SpotifyManagerError?
        let operationQueue = OperationQueue()

        func cancel() {
            operationQueue.cancelAllOperations()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

        // Step 1: Fetch the current playing playlist

        var playbackPlaylistInfo: (userID: String, playlistID: String)?

        let fetchPlaybackOperation = WKROperation()
        fetchPlaybackOperation.addExecutionBlock {
            self.fetchPlayback(completion: { (response, fetchError) in
                if let response = response?.playlistInfo {
                    playbackPlaylistInfo = response
                } else {
                    error = fetchError
                    cancel()
                }
                fetchPlaybackOperation.state = .isFinished
            })
        }
        operationQueue.addOperation(fetchPlaybackOperation)

        // Step 2: Fetch the playlist metadata and all the playlist tracks

        var playlistResponse: PlaylistResponse?
        var playlistTracksResponses = [PlaylistTracksResponse]()

        let fetchPlaylistOperation = WKROperation()
        fetchPlaylistOperation.addExecutionBlock {
            guard let playlistInfo = playbackPlaylistInfo else { fatalError() }
            self.fetchPlaylist(info: playlistInfo) { response, fetchError in
                if let response = response {
                    playlistResponse = response
                } else {
                    error = fetchError
                    cancel()
                }
                fetchPlaylistOperation.state = .isFinished
            }
        }
        fetchPlaylistOperation.addDependency(fetchPlaybackOperation)
        operationQueue.addOperation(fetchPlaylistOperation)

        let fetchTracksOperation = WKROperation()
        fetchTracksOperation.addExecutionBlock {
            guard let playlistInfo = playbackPlaylistInfo else { fatalError() }
            self.fetchPlaylistTracks(info: playlistInfo) { response, fetchError in
                if let response = response {
                    playlistTracksResponses.append(response)
                } else {
                    error = fetchError
                    cancel()
                }
                fetchTracksOperation.state = .isFinished
            }
        }
        fetchTracksOperation.addDependency(fetchPlaybackOperation)
        operationQueue.addOperation(fetchTracksOperation)

        // Step 3: Create new playlist after playlist metadata gathered

        var createdPlaylistResponse: PlaylistResponse?

        let createPlaylistOperation = WKROperation()
        createPlaylistOperation.addExecutionBlock {
            guard let playlistResponse = playlistResponse else { fatalError() }

            var params: [String: Any] = ["name": playlistResponse.name + "-Shuffled", "public": false]
            if let description = playlistResponse.description {
                params[description] = description
            }

            self.createPlaylist(params: params) { response, fetchError  in
                if let response = response {
                    createdPlaylistResponse = response
                } else {
                    error = fetchError
                    cancel()
                }
                createPlaylistOperation.state = .isFinished
            }
        }
        createPlaylistOperation.addDependency(fetchPlaylistOperation)
        operationQueue.addOperation(createPlaylistOperation)

        // Step 4: Fill new playlist with sorted tracks

        let addTracksOperation = WKROperation()
        addTracksOperation.addExecutionBlock {
            guard let createdPlaylistResponse = createdPlaylistResponse else { fatalError() }

            let uris = playlistTracksResponses.map({ $0.items })
                .reduce([], +)
                .map({ $0.track.uri })

            guard let magic = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: uris) as? [String] else {
                fatalError()
            }

            self.addToPlaylist(id: createdPlaylistResponse.id, uris: magic, completion: { addError in
                if let addError = addError {
                    error = addError
                    cancel()
                } else {
                    print("Success")
                    DispatchQueue.main.async {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
                addTracksOperation.state = .isFinished
            })
        }
        addTracksOperation.addDependency(fetchTracksOperation)
        addTracksOperation.addDependency(createPlaylistOperation)
        operationQueue.addOperation(addTracksOperation)
    }

    // MARK: - Authentication

    func handle(url: URL) -> Bool {
        print("SpotifyManager: " + #function)

        guard auth.canHandle(auth.redirectURL) else {
            return false
        }

        SpotifyManager.shared.auth.handleAuthCallback(withTriggeredAuthURL: url) { error, session in
            if let error = error {
                print("SpotifyManager: " + #function + " error: \(error)")
            } else if let session = session {
                print("SpotifyManager: " + #function + " got session")
                let data = NSKeyedArchiver.archivedData(withRootObject: session)
                Defaults.set(data, for: .session)
                self.session = session

                self.fetchProfile(completion: { (response, error) in
                    if let error = error {
                        print("SpotifyManager: " + #function + " Profile error: \(error)")
                    } else if let response = response {
                        print("SpotifyManager: " + #function + " Fetched Profile")
                        self.sessionUserID = response.id
                        Defaults.set(response.id, for: .userID)
                    }
                })
            }
        }

        return true
    }

    func presentLogInViewController(from viewController: UIViewController) {
        auth.clientID = Secrets.spotifyClientID
        auth.redirectURL = URL(string:"SpotifyShuffler://callback")!

        auth.requestedScopes = [
            SPTAuthPlaylistReadPrivateScope,
            SPTAuthPlaylistReadCollaborativeScope,
            SPTAuthPlaylistModifyPublicScope,
            SPTAuthPlaylistModifyPrivateScope,
            "user-read-playback-state"
        ]

        guard let appURL = auth.spotifyAppAuthenticationURL(),
            let webURL = auth.spotifyWebAuthenticationURL() else {
                fatalError()
        }

        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            let controller = SFSafariViewController(url: webURL)
            viewController.present(controller, animated: true, completion: nil)
        }

    }

    // MARK: - Spotify Web API POST

    private func addToPlaylist(id: String,
                               uris: [String],
                               completion: @escaping (_ error: SpotifyManagerError?) -> ()) {
        print("SpotifyManager: " + #function)

        guard let userID = sessionUserID,
            let accessToken = session?.accessToken else {
                completion(.authentication)
                return
        }

        let urisJoined = uris.joined(separator: ",")
        let urlString = "https://api.spotify.com/v1/users/\(userID)/playlists/\(id)/tracks?uris=" + urisJoined

        guard let url = URL(string: urlString) else {
            fatalError()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                print("SpotifyManager: " + #function + " error: \(error)")
                completion(.network)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }

    private func createPlaylist(params: [String: Any],
                                completion: @escaping (_ playlistResponse: PlaylistResponse?, _ error: SpotifyManagerError?) -> ()) {
        print("SpotifyManager: " + #function)

        guard let url = URL(string: "https://api.spotify.com/v1/users/j3d1_warr10r/playlists"),
            let httpBody = try? JSONSerialization.data(withJSONObject: params),
            let accessToken = session?.accessToken else {
                completion(nil, .authentication)
                return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                print("SpotifyManager: " + #function + " error: \(error)")
                completion(nil, .network)
            } else if let data = data,
                let response = try? self.decoder.decode(PlaylistResponse.self, from: data) {
                print("SpotifyManager: " + #function + " got response")
                completion(response, nil)
            } else {
                print("SpotifyManager: " + #function + " response error")
                completion(nil, .response)
            }
        }
        task.resume()
    }

    // MARK: - Spotify Web API GET

    private func fetchProfile(completion: @escaping (_ profileResponse: ProfileResponse?, _ error: SpotifyManagerError?) -> ()) {
        print("SpotifyManager: " + #function)

        guard let url = URL(string: "https://api.spotify.com/v1/me"),
            let accessToken = session?.accessToken else {
                completion(nil, .authentication)
                return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                print("SpotifyManager: " + #function + " error: \(error)")
                completion(nil, .network)
            } else if let data = data,
                let response = try? self.decoder.decode(ProfileResponse.self, from: data) {
                print("SpotifyManager: " + #function + " got response")
                completion(response, nil)
            } else {
                print("SpotifyManager: " + #function + " response error")
                completion(nil, .response)
            }
        }
        task.resume()
    }

    private func fetchPlayback(completion: @escaping (_ playbackResponse: PlaybackResponse?, _ error: SpotifyManagerError?) -> ()) {
        print("SpotifyManager: " + #function)

        guard let url = URL(string: "https://api.spotify.com/v1/me/player"),
            let accessToken = session?.accessToken else {
            completion(nil, .authentication)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                print("SpotifyManager: " + #function + " error: \(error)")
                completion(nil, .network)
            } else if let data = data,
                let response = try? self.decoder.decode(PlaybackResponse.self, from: data) {
                print("SpotifyManager: " + #function + " got response")
                completion(response, nil)
            } else {
                print("SpotifyManager: " + #function + " response error")
                completion(nil, .response)
            }
        }
        task.resume()
    }

    private func fetchPlaylist(info: (userID: String, playlistID: String),
                               completion: @escaping (_ playlistResponse: PlaylistResponse?, _ error: SpotifyManagerError?) -> ()) {
        print("SpotifyManager: " + #function)

        let string = "https://api.spotify.com/v1/users/\(info.userID)/playlists/\(info.playlistID)?fields=id,name,description"
        guard let url = URL(string: string),
            let accessToken = session?.accessToken else {
                completion(nil, .authentication)
                return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                print("SpotifyManager: " + #function + " error: \(error)")
                completion(nil, .network)
            } else if let data = data,
                let response = try? self.decoder.decode(PlaylistResponse.self, from: data) {
                print("SpotifyManager: " + #function + " got response")
                completion(response, nil)
            } else {
                print("SpotifyManager: " + #function + " response error")
                completion(nil, .response)
            }
        }
        task.resume()
    }

    private func fetchPlaylistTracks(info: (userID: String, playlistID: String),
                       completion: @escaping (_ playlistTracksResponse: PlaylistTracksResponse?, _ error: SpotifyManagerError?) -> ()) {
        print("SpotifyManager: " + #function)

        let string = "https://api.spotify.com/v1/users/\(info.userID)/playlists/\(info.playlistID)/tracks"
        guard let url = URL(string: string),
             let accessToken = session?.accessToken else {
                completion(nil, .authentication)
                return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                print("SpotifyManager: " + #function + " error: \(error)")
                completion(nil, .network)
            } else if let data = data,
                let response = try? self.decoder.decode(PlaylistTracksResponse.self, from: data) {
                print("SpotifyManager: " + #function + " got response")
                completion(response, nil)
            } else {
                print("SpotifyManager: " + #function + " response error")
                completion(nil, .response)
            }
        }
        task.resume()
    }

}
