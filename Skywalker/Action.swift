//
//  Action.swift
//  Skywalker
//
//  Created by Jais Cheema on 23/4/17.
//  Copyright © 2017 Needle Apps. All rights reserved.
//

import Foundation

class Action: NSObject, NSCoding {
    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let timeInterval = aDecoder.decodeDouble(forKey: "timeInterval")
        self.timeInterval = timeInterval
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {}
    
    func applyTo(gameState: GameState) -> GameState {
        return gameState
    }
    
    public static func ==(lhs: Action, rhs: Action) -> Bool {
        return lhs.timeInterval == rhs.timeInterval
    }
}

class StartGame: Action {
    override func applyTo(gameState: GameState) -> GameState {
        var newGameState = gameState
        newGameState.status = .awaitingStartingPlayer
        return newGameState
    }
    
    override var description: String {
        return "StartGame"
    }
}

class SetCurrentPlayer: Action {
    let playerIdentifier: String
    
    init(timeInterval: TimeInterval, playerIdentifier: String) {
        self.playerIdentifier = playerIdentifier
        super.init(timeInterval: timeInterval)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let identifier = aDecoder.decodeObject(forKey: "identifier") as? String else { return nil }
        self.playerIdentifier = identifier
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(playerIdentifier, forKey: "identifier")
    }
    
    override var description: String {
        return "SetCurrentPlayer: \(playerIdentifier)"
    }
    
    override func applyTo(gameState: GameState) -> GameState {
        var newGameState = gameState
        newGameState.currentPlayerIdentifier = playerIdentifier
        newGameState.status = .awaitingPlay
        return newGameState
    }
}

class ChoiceAction: Action {
    let value: GameSelection
    
    init(timeInterval: TimeInterval, value: GameSelection) {
        self.value = value
        super.init(timeInterval: timeInterval)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let intValue = aDecoder.decodeInteger(forKey: "value")
        guard let selection = GameSelection(rawValue: intValue) else { return nil }
        self.value = selection
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(value.rawValue, forKey: "value")
    }
    
    override var description: String {
        return "MakeSelection: \(value.rawValue)"
    }
    
    override func applyTo(gameState: GameState) -> GameState {
        guard let identifier = gameState.currentPlayerIdentifier else { return gameState }
        var newGameState = gameState
        newGameState.playerChoices[identifier] = value
        newGameState.status = .turnComplete
        return newGameState
    }
}

class SetWinner: Action {
    let playerIdentifier: String
    
    init(timeInterval: TimeInterval, playerIdentifier: String) {
        self.playerIdentifier = playerIdentifier
        super.init(timeInterval: timeInterval)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let identifier = aDecoder.decodeObject(forKey: "identifier") as? String else { return nil }
        self.playerIdentifier = identifier
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(playerIdentifier, forKey: "identifier")
    }
    
    override var description: String {
        return "SetWinner: \(playerIdentifier)"
    }
    
    override func applyTo(gameState: GameState) -> GameState {
        var newGameState = gameState
        newGameState.currentPlayerIdentifier = nil
        newGameState.status = .finished(winner: playerIdentifier)
        return newGameState
    }
}