//
//  GameCenterMatch.swift
//  Skywalker
//
//  Created by Jais Cheema on 25/4/17.
//  Copyright © 2017 Needle Apps. All rights reserved.
//

import Foundation
import GameKit

class GameCenterMatch: Match {
    private(set) var turnBasedMatch: GKTurnBasedMatch
    
    override var currentPlayer: Player? {
        guard let currentParticipant = self.turnBasedMatch.currentParticipant else { return nil }
        guard let index = self.turnBasedMatch.participants!.index(of: currentParticipant) else { return nil }
        return self.players[index]
    }
    
    init(turnBasedMatch: GKTurnBasedMatch) {
        self.turnBasedMatch = turnBasedMatch
        let players = (turnBasedMatch.participants ?? []).map { $0.mPlayer }
        super.init(identifier: turnBasedMatch.matchID ?? RandomIdentifier(),
                   players: players,
                   localPlayerIdentifier: GKLocalPlayer.localPlayer().playerID ?? players.first!.identifier,
                   status: .running,
                   matchData: turnBasedMatch.matchData)
    }
    
    override func saveTurnWith(nextPlayer: Player?) {
        if let nextPlayer = nextPlayer {
            let nextParticipants = nextParticipantArray(nextPlayerIdentifier: nextPlayer.identifier)
            self.turnBasedMatch.endTurn(withNextParticipants: nextParticipants, turnTimeout: 0, match: matchData, completionHandler: nil)
        } else {
            self.turnBasedMatch.saveCurrentTurn(withMatch: matchData, completionHandler: nil)
        }
    }
    
    override func endMatch(winner: Player) {
        self.turnBasedMatch.participants?.forEach { participant in
            if participant.player?.playerID == winner.identifier  {
                participant.matchOutcome = .won
            } else {
                participant.matchOutcome = .lost
            }
        }
        self.turnBasedMatch.endMatchInTurn(withMatch: matchData, completionHandler: nil)
    }
    
    func update(turnBasedMatch: GKTurnBasedMatch) {
//        let maxTimeInterval = self.actions.keys.max() ?? 0
//        let updatedActions = ActionsFrom(matchData: turnBasedMatch.matchData ?? Data())
//        let newActions = updatedActions.filter { (key, _) in key > maxTimeInterval }
//        newActions.forEach { (key, value) in
//            self.game.add(action: value)
//            self.add(action: value, atTimeInterval: key)
//        }
        // update the players
        // update the instance
        // run the actions received on the game
    }
    
    func nextParticipantArray(nextPlayerIdentifier: String) -> [GKTurnBasedParticipant] {
        let participants = self.turnBasedMatch.participants ?? []
        let index = self.players.index { $0.identifier == nextPlayerIdentifier } ?? 0
        return participants.shift(withDistance: index)
    }
}