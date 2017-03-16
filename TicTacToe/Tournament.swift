//
//  Tournament.swift
//  TicTacToe
//
//  Created by Sunny Egbo on 6/26/16.
//  Copyright © 2016 Unatezesoft, LLC. All rights reserved.
//
// Abstract:
// Contains the Tournament which manages the game and game statistics.

import Foundation

class Tournament {
    var gamesPlayed = 0
    var gamesWonByX = 0
    var gamesWonByO = 0
    
    var game = TicTacToe()
    
    func newGame() {
        game = TicTacToe()
    }
}