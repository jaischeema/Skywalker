//
//  Match.swift
//  Skywalker
//
//  Created by Jais Cheema on 23/4/17.
//  Copyright © 2017 Needle Apps. All rights reserved.
//

import Foundation
import GameKit

struct Player {
    let identifier: String
    let displayName: String
    let isTemp: Bool
    
    init(identifier: String, displayName: String, isTemp: Bool = false) {
        self.identifier = identifier
        self.displayName = displayName
        self.isTemp = isTemp
    }
    
    init() {
        self.init(identifier: RandomIdentifier(),
                  displayName: "Matching",
                  isTemp: true)
    }
}

func ActionsFrom(matchData: Data) -> [Action] {
    guard let actions = NSKeyedUnarchiver.unarchiveObject(with: matchData) as? [Action] else {
        return []
    }
    return actions
}

enum MatchStatus {
    case notStarted
    case running
    case finished
}

class Match {
    let identifier: String
    let localPlayerIdentifier: String
   
    var currentPlayer: Player? { return nil }
    
    private(set) var status: MatchStatus
    
    var players: [Player]
    var actions: [Action]
    
    var matchData: Data {
        return NSKeyedArchiver.archivedData(withRootObject: self.actions)
    }
    
    var isLocalPlayerActive: Bool {
        return localPlayerIdentifier == self.currentPlayer?.identifier
    }
    
    private var _game: Game?
    var game: Game {
        if _game == nil {
            _game = Game(match: self)
        }
        return _game!
    }
    
    init(identifier: String, players: [Player], localPlayerIdentifier: String, status: MatchStatus, matchData: Data?) {
        self.identifier = identifier
        self.players = players
        self.localPlayerIdentifier = localPlayerIdentifier
        self.status = status
        self.actions = ActionsFrom(matchData: matchData ?? Data())
        NotificationCenter.default.addObserver(self, selector: #selector(handleGameEvent), name: GameNotificationName, object: nil)
    }
    
    func saveTurnWith(nextPlayer: Player?) {
    }
    
    func endMatch(winner: Player) {
    }
    
    func playerFor(identifier: String) -> Player? {
        return self.players.first { $0.identifier == identifier }
    }
    
    @objc func handleGameEvent(_ notification: Notification) {
        if let action = notification.object as? Action {
            guard !self.actions.contains(action) else { return }
            print(action.timeInterval)
            self.actions.append(action)
            
            switch action {
            case let currentAction as SetCurrentPlayer:
                if self.currentPlayer?.identifier != currentAction.playerIdentifier {
                    self.saveTurnWith(nextPlayer: playerFor(identifier: currentAction.playerIdentifier))
                } else {
                    self.saveTurnWith(nextPlayer: nil)
                }
            case let currentAction as SetWinner:
                self.endMatch(winner: playerFor(identifier: currentAction.playerIdentifier)!)
            default:
                self.saveTurnWith(nextPlayer: nil)
            }
        }
    }
}