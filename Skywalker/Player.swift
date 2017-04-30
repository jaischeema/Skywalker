//
//  Player.swift
//  Skywalker
//
//  Created by Jais Cheema on 30/4/17.
//  Copyright © 2017 Needle Apps. All rights reserved.
//

import Foundation

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
