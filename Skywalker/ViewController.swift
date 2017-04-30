//
//  ViewController.swift
//  Skywalker
//
//  Created by Jais Cheema on 23/4/17.
//  Copyright © 2017 Needle Apps. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {
    @IBOutlet weak var twoPlayerButton: UIButton!
    
    var match: GameCenterMatch?
    
    var isLoggedIn: Bool = false {
        didSet {
            self.twoPlayerButton.isEnabled = isLoggedIn
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.register(self)
        localPlayer.authenticateHandler = { (viewController, error) in
            guard let vc = viewController else {
                self.isLoggedIn = localPlayer.isAuthenticated
                return
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func twoPlayerGame() {
        createMatch(players: 2)
    }
    
    func createMatch(players: Int) {
        guard isLoggedIn else { return }
        
        let matchRequest = GKMatchRequest()
        matchRequest.defaultNumberOfPlayers = players
        matchRequest.maxPlayers = players
        matchRequest.minPlayers = players
        let controller = GKTurnBasedMatchmakerViewController(matchRequest: matchRequest)
        controller.turnBasedMatchmakerDelegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartGame", let viewController = segue.destination as? GameViewController, match != nil  {
            viewController.game = match!.game
        }
    }
}

extension ViewController: GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print(error.localizedDescription)
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: GKLocalPlayerListener {
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        guard let currentMatch = self.match else {
            self.dismiss(animated: true) {
                self.match = GameCenterMatch(turnBasedMatch: match)
                self.performSegue(withIdentifier: "StartGame", sender: self)
            }
            return
        }
        if(match.matchID == currentMatch.identifier) {
            currentMatch.update(turnBasedMatch: match)
        }
        // How to handle if the match we recevied updates is not the active one
    }
    
    func player(_ player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) {
        print("Did Request match with other players")
    }
    
    func player(_ player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        print("Match ended")
    }
}
