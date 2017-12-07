//
//  ViewController.swift
//  SpotifyShuffler
//
//  Created by Andrew Finke on 12/6/17.
//  Copyright © 2017 Andrew Finke. All rights reserved.
//

import UIKit
import GameplayKit
import SafariServices


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

        SpotifyManager.shared.fetchPlaylistName { (title, error) in
            if let title = title {
                DispatchQueue.main.async {
                    self.nowPlayingLabel.text = title
                }
            }
        }
    }

    func setupInterface() {
        button.layer.cornerRadius = button.frame.width / 2

        keepPlayingSwitch.isOn = Defaults.value(for: .keepPlaying) ?? false
        openSwitch.isOn = Defaults.value(for: .alwaysOpen) ?? false

        if SpotifyManager.shared.isAuthenticated {
            button.setTitle("Shuffle", for: .normal)
        } else {
            button.setTitle("Log In", for: .normal)
        }
    }

    // MARK: - Actions

    @IBAction func buttonPressed(_ sender: Any) {
        UISelectionFeedbackGenerator().selectionChanged()
        if SpotifyManager.shared.isAuthenticated {
            SpotifyManager.shared.createShuffledPlaylist(overwrite: false)
        } else {
            SpotifyManager.shared.presentLogInViewController(from: self)
        }
    }

    @IBAction func keepPlayingSwitchFlipped(_ sender: Any) {
        Defaults.set(keepPlayingSwitch.isOn, for: .keepPlaying)
    }

    @IBAction func openSwitchFlipped(_ sender: Any) {
        Defaults.set(openSwitch.isOn, for: .alwaysOpen)
    }

}
