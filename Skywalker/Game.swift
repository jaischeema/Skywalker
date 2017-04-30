//
//  Game.swift
//  Skywalker
//
//  Created by Jais Cheema on 25/4/17.
//  Copyright © 2017 Needle Apps. All rights reserved.
//

import Foundation
import QuartzCore

// state, action

enum GameSelection: Int {
    case rock = 1
    case paper = 2
    case scissor = 3
    case spock = 4
    case lizard = 5
    
    init?(rawStringValue: String) {
        switch rawStringValue {
        case "Rock": self = .rock
        case "Paper": self = .paper
        case "Scissor": self = .scissor
        case "Spock": self = .spock
        case "Lizard": self = .lizard
        default: return nil
        }
    }
}

let GameNotificationName = Notification.Name(rawValue: "GameNotification")

enum GameStatus {
    case notStarted
    case awaitingStartingPlayer
    case awaitingPlay
    case turnComplete
    case finished(winner: String)
    
    var isFinished: Bool {
        switch self {
        case .finished(_):
            return true
        default:
            return false
        }
    }
}

struct GameState {
    var currentPlayerIdentifier: String?
    var status: GameStatus
    var playerChoices: [String: GameSelection]
    
    init() {
        self.currentPlayerIdentifier = nil
        self.status = .notStarted
        self.playerChoices = [:]
    }
}

class Game {
    let match: Match
    var state: GameState
    
    var currentPlayer: Player? {
        guard let identifier = state.currentPlayerIdentifier else { return nil }
        return self.players.first { $0.identifier == identifier }
    }
    
    var actions: [Action] = []
    var hasUnprocessedAction: Bool { return self.actions.count > 0 }
    
    // Match delegates
    var players: [Player] { return match.players }
    var localPlayerIdentifier: String { return match.localPlayerIdentifier }
    var isServer: Bool { return match.isLocalPlayerActive }
    
    init(match: Match) {
        self.match = match
        self.state = GameState()
        match.actions.sorted { $0.0.timeInterval < $0.1.timeInterval }.forEach { self.add(action: $0) }
    }
    
    func start() {
        let updater = CADisplayLink(target: self, selector: #selector(self.process))
        if #available(iOS 10.0, *) {
            updater.preferredFramesPerSecond = 60
        }
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    @objc func process() {
        if hasUnprocessedAction {
            let action = actions.removeFirst()
            self.state = action.applyTo(gameState: state)
            NotificationCenter.default.post(name: GameNotificationName, object: action)
        }
        
        guard !hasUnprocessedAction && isServer else { return }

        let currentTime = Date().timeIntervalSince1970
        switch self.state.status {
        case .notStarted:
            self.add(action: StartGame(timeInterval: currentTime))
        case .awaitingStartingPlayer:
            self.add(action: SetCurrentPlayer(timeInterval: currentTime, playerIdentifier: self.players.first!.identifier))
        case .turnComplete:
            guard let player = self.currentPlayer else { return }
            if self.state.playerChoices.count == self.players.count {
                self.add(action: SetWinner(timeInterval: currentTime, playerIdentifier: player.identifier))
            } else {
                let nextPlayer = self.nextPlayer(player: player)
                self.add(action: SetCurrentPlayer(timeInterval: currentTime, playerIdentifier: nextPlayer.identifier))
            }
        default: break
        }
    }
    
    func add(action: Action) {
        self.actions.append(action)
    }
    
    func nextPlayer(player: Player) -> Player {
        let index = self.players.index { $0.identifier == player.identifier } ?? 0
        return players.shift(withDistance: index + 1)[0]
    }
}
