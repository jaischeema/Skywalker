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
    @IBOutlet weak var leftPlayerLabel: UILabel!
    @IBOutlet weak var rightPlayerLabel: UILabel!
    @IBOutlet weak var updatesView: UITextView!
    
    var currentPlayerIsActive: Bool {
       return GKLocalPlayer.localPlayer().playerID == self.game.currentPlayer?.identifier
    }
    
    var allActionButtons: [UIButton] {
        return [rockButton, paperButton, scissorButton, spockButton, lizardButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameEvent), name: GameNotificationName, object: nil)
    }
    
    func handleGameEvent(_ notification: Notification) {
        if let action = notification.object as? Action {
            self.actions.append(action)
        }
        self.updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.game.players.count == 2 {
            self.bottomPlayerLabel.text = self.game.players[0].displayName
            self.topPlayerLabel.text = self.game.players[1].displayName
            self.leftPlayerLabel.text = ""
            self.rightPlayerLabel.text = ""
        } else if self.game.players.count == 4 {
            self.bottomPlayerLabel.text = self.game.players[0].displayName
            self.leftPlayerLabel.text = self.game.players[1].displayName
            self.leftPlayerLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            self.leftPlayerLabel.sizeToFit()
            self.topPlayerLabel.text = self.game.players[2].displayName
            self.rightPlayerLabel.text = self.game.players[3].displayName
            self.rightPlayerLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            self.rightPlayerLabel.sizeToFit()
        }
        self.updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.game.start()
    }
    
    @IBAction func runAction(sender: UIButton) {
        guard currentPlayerIsActive else { return }
        guard let buttonTitle = sender.currentTitle else { return }
        guard let gameSelection = GameSelection(rawStringValue: buttonTitle) else { return }
        self.game.add(action: ChoiceAction(timeInterval: Date().timeIntervalSince1970, value: gameSelection))
    }
    
    func updateView() {
        let text = self.actions.map { $0.description }.joined(separator: "\n")
        self.updatesView.text = text
        allActionButtons.forEach { $0.isEnabled = currentPlayerIsActive }
    }
}
