//
//  TicTacToe.swift
//  TicTacToe
//
//  Created by Sunny Egbo on 5/23/16.
//  Copyright © 2016 Unatezesoft, LLC. All rights reserved.
/*
 Abstract:
 Contains the TicTacToe game model that implements an almost exact solution of Tic Tac Toe with a touch of randomness that allows the human player (player 1) to win with some moves. Although there is an exact solution to Tic Tac Toe that guarantees that the computer never looses, this solution has an element of randomnes where the human player can win on some occassions.
 
This implementation uses two bitmaps to represent the state of the game board. One bitmap marks the positions played by X (Player 1) in the game, while the other bitmap contains the positions played by O (player 2). When a player plays a position, the bit position played is toggled to 1 for that player's board bitmap after checking that the position is still available. At any point during the game, the two bitmaps can be bitwise or'ed to determine all occupied (or available) positions in the game. Also, checking for wins is easy; winnings can be determined by bitwise and'ing a given player's bitmap with well known winning bit patterns stored in a dictionary.
*/

import Foundation


class TicTacToe
{
    //MARK: - Public var
    var numberOfPositions: Int { // readonly
        return 9
    }
    
    //MARK: - Private var
    fileprivate var xBoard = 0
    fileprivate var oBoard = 0
    fileprivate let winningPositions: Dictionary<Int, [Int]> = [
        0x7: [0, 1, 2], // First Row winning pattern
        0x38: [3,4,5],  // Middle Row winning pattern
        0x1C0: [6,7,8], // Last Row winning pattern
        0x49:  [0, 3, 6], // First Column winning pattern
        0x92:  [1, 4, 7], // Second Column winning pattern
        0x124: [2, 5, 8], // Last Column winning pattern
        0x111: [0, 4, 8], // Left Diagonal winning pattern
        0x54:  [2, 4, 6], // Right Diagonal winning pattern
    ]
    
    //MARK: - Public func
    
    /// Plays a position for player 1
    /// - parameter position: the number position to play for player 1

    func player1PlaysPosition(_ position: Int)
    {
        guard position < numberOfPositions else { return }
        
        let toggleBit = 1 << position
        xBoard = xBoard | toggleBit
    }
    
    /// Plays a position for player 2
    /// - parameter position: the number position to play for player 2
    
    func player2PlaysPosition(_ position: Int)
    {
        guard position < numberOfPositions else { return }
        
        let toggleBit = 1 << position
        oBoard = oBoard | toggleBit
    }
    
    /// Returns whether someone can still win the game or that we have reached a stalemate
    /// in the game
    /// - returns: true when the game is in a stalemate, false otherwise
    
    func nobodyCanWin() -> Bool
    {
        return ((xBoard | oBoard) == 0x1FF)
    }
    
    /// Returns whether player 1 is the winner
    /// - returns: true when player 1 is the winner, false otherwise

    func player1Won() -> Bool
    {
        return isWinnerBoard(xBoard)
    }
    
    /// Returns whether player 2 is the winner
    /// - returns: true when player 2 is the winner, false otherwise
    
    func player2Won() -> Bool
    {
        return isWinnerBoard(oBoard)
    }
    
    /// Returns the positions resulting in a win
    /// - returns: an array of board indices for that resulted in the win
    
    func winningCells() -> [Int]
    {
        if player1Won() {
            return positionsOnWinningBoard(xBoard)
        }
        else {
            return positionsOnWinningBoard(oBoard)
        }
    }

    /// Calculates a move for player 2
    /// To start, Look for a winning next move to take.
    /// If none, then look for a winning move for player 1 to block.
    /// Otherwise, look for a couple of well known patterns.
    /// Finally, choose a random available position when all else fails.
    /// - returns: a position for player 2 to play

    func nextMoveForPlayer2() -> Int
    {
        var position = 0
        var nextWinningPositionForPlayer1 = -1
        var nextWinningPositionForPlayer2 = -1
        
        for i in 0..<numberOfPositions { // Take or block next winning move
            if availablePosition(i) {
                if winsBoard(oBoard, withPosition: i) {
                    nextWinningPositionForPlayer2 = i
                    break    // Found a winning position for player 2, stop searching and take it
                }
                else if winsBoard(xBoard, withPosition: i) {
                    nextWinningPositionForPlayer1 = i  // player 1's potential winning position that can be to blocked
                }
            }
        }

        if nextWinningPositionForPlayer2 > -1 {
            position = nextWinningPositionForPlayer2
        }
        else if nextWinningPositionForPlayer1 > -1 {
            position = nextWinningPositionForPlayer1
        }
        else if availablePosition(4) {
            position = 4
        }
        else if (xBoard == 0x44) || (xBoard == 0xC) {
            position = 1
        }
        else if ( ((xBoard == 0x42) || (xBoard == 0x108) || (xBoard == 0x102)) && availablePosition(0) )  {
            position = 0
        }
        else if ( ((xBoard == 0xC0) || (xBoard == 0x24) || (xBoard == 0xA4)) && availablePosition(8) )  {
            position = 8
        }
        else {
            position = randomComputerMove()
        }
        return position
    }
    
    
    //MARK: - Private func

    /// Private method to determine whether a given game position is still available by checking 
    /// each player's bitmap (i.e., xBoard and oBoard)
    /// - parameter position: the position to check
    /// - returns: true or false

    fileprivate func availablePosition(_ position: Int) -> Bool
    {
        let checkBit = 1 << position
        return ((xBoard & checkBit) == 0) && ((oBoard & checkBit) == 0)
    }

    /// Private method to determine whether a given player's bitmap (i.e., xBoard and oBoard) is a winner by 
    /// checking the bitmap against known winning bitmaps. This is done by bitwise 'and' between all known 
    /// winning bit pattern against player's board
    /// - parameter board: the player's board that need to be checked
    /// - returns: true or false
    
    fileprivate func isWinnerBoard(_ board: Int) -> Bool
    {
        let winnings = (winningPositions.keys).filter{$0 & board == $0}
        return winnings.count > 0
    }
    
    /// Private method to return the positions contributing a winning move
    /// - parameter board: the player's board that need to be checked
    /// - returns: an array of positions

    fileprivate func positionsOnWinningBoard(_ board: Int) -> [Int]
    {
        let winnings = (winningPositions.keys).filter{$0 & board == $0}
        if let keyValue = winnings.first, let positions = winningPositions[keyValue] {
            return positions
        }

        return []
    }

    /// Private method to return whether a given player's board can win if the player plays a given position
    /// - parameter board: the player's board that need to be checked
    /// - parameter position: the position to be checked
    /// - returns: true or false
    
    fileprivate func winsBoard(_ initialBoard: Int, withPosition position: Int) -> Bool
    {
        let checkBit = 1 << position
        let board = initialBoard | checkBit
        return isWinnerBoard(board)
    }
    
    /// Private method to draw a random available position
    /// - returns: a position
    
    fileprivate func randomComputerMove() -> Int
    {
        var position = 0
        
        repeat {
            position = Int(arc4random_uniform(UInt32(numberOfPositions-1)))
        } while !availablePosition(position)
        
        return position
    }
    
}
