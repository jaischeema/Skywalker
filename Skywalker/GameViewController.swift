//
//  GameViewController.swift
//  Skywalker
//
//  Created by Jais Cheema on 23/4/17.
//  Copyright © 2017 Needle Apps. All rights reserved.
//

import UIKit
import GameKit

class GameViewController: UIViewController {
    var game: Game!
    var gameState = GameState()
   
    var actions: [Action] = []
    
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var paperButton: UIButton!
    @IBOutlet weak var scissorButton: UIButton!
    @IBOutlet weak var spockButton: UIButton!
    @IBOutlet weak var lizardButton: UIButton!
    
    @IBOutlet weak var topPlayerLabel: UILabel!
    @IBOutlet weak var bottomPlayerLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var currentPlayerIsActive: Bool {
        guard let index = self.gameState.currentPlayerIndex else { return false }
        return GKLocalPlayer.localPlayer().playerID == self.game.players[index].identifier
    }
    
    var currentPlayerIndex: Int {
        for (index, player) in self.game.players.enumerated() {
            if player.identifier == GKLocalPlayer.localPlayer().playerID {
                return index
            }
        }
        assert(false, "This should never be triggered")
        return 0
    }
    
    var allActionButtons: [UIButton] {
        return [rockButton, paperButton, scissorButton, spockButton, lizardButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleGameEvent),
                                               name: GameNotificationName,
                                               object: nil)
    }
    
    func handleGameEvent(_ notification: Notification) {
        if let action = notification.object as? Action {
            self.actions.append(action)
            self.gameState = action.applyTo(gameState: gameState)
        }
        self.updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bottomPlayerLabel.text = self.game.players[0].displayName
        self.topPlayerLabel.text = self.game.players[1].displayName
        self.updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.game.start()
    }
    
    @IBAction func runAction(sender: UIButton) {
        guard currentPlayerIsActive else { return }
        guard let gameSelection = GameSelection(rawValue: sender.tag) else { return }
        self.game.add(action: ChoiceAction(timeInterval: Date().timeIntervalSince1970, value: gameSelection))
    }
    
    func updateView() {
        allActionButtons.forEach { $0.isEnabled = currentPlayerIsActive }
        
        if let currentSelection = self.gameState.playerChoices[self.currentPlayerIndex] {
            for button in allActionButtons {
                guard let selection = GameSelection(rawValue: button.tag) else { continue }
                if currentSelection == selection {
                    button.layer.borderColor = UIColor.yellow.cgColor
                    button.layer.borderWidth = 2.0
                    button.layer.cornerRadius = rockButton.frame.width / 2.0
                    button.clipsToBounds = false
                }
            }
        }

        switch self.gameState.status {
        case .awaitingPlay:
            self.statusLabel.text = currentPlayerIsActive ? "Your turn!!" : "Waiting for another player :/"
        case .finished(let results):
            guard let result = results[currentPlayerIndex] else { return }
            switch result {
            case .lost:
                self.statusLabel.text = "You lost :("
            case .won:
                self.statusLabel.text = "You won \\o/"
            case .tie:
                self.statusLabel.text = "Oh no! Its a tie :|"
            }
        default:
            self.statusLabel.text = ""
        }
    }
}
