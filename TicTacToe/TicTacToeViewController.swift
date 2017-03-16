//
//  TicTacToeViewController.swift
//  TicTacToe
//
//  Created by Sunny Egbo on 5/23/16.
//  Copyright © 2016 Unatezesoft, LLC. All rights reserved.
//
/*
 Abstract:
 Contains the TicTacToeViewController which is a collectionView with cells for each position in the game. The controller implements a method to check a user's tap gesture on an available cell in order to play a position. It maintains a data structure for the tournament and methods to update tournament statistics and inform the user when a game ends in the tournament.
 */

import UIKit


class TicTacToeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    
    //MARK: Private var
    fileprivate struct StoryBoard
    {
        static let cellReuseIdentifier = "GameCell"
        static let footerReuseIdentifier = "GameFooter"
        static let navBarSpacing = CGFloat(64.0)
        static let cellsPerRow = 3
    }
    fileprivate struct AlertMessage
    {
        static let youWin = "Congratulations! You won."
        static let youLoose = "Your opponent won."
        static let nobodyWins = "This game ended in a stalemate."
        static let title = "Game over!"
        static let ok = "Ok"
    }
    fileprivate let tournament = Tournament()
    fileprivate weak var gameFooterView: TicTacToeFooterView!
        
    
    //MARK: View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 40.0/255.0, green: 140.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        let titleDict: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = titleDict
        /// make modal segues for viewcontrollers that have clear / see-through backgrounds work
        self.modalPresentationStyle = .overFullScreen
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true

        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TicTacToeViewController.handleTapGestureRecognizer(_:))))
    }

    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    
    //MARK: - Gestures
    
    /// Method to check taps on the collectionView. Determines which individual cell (if any) is tapped.
    /// If an available cell is tapped, mark that cell for player 1, check whether player 1 won or that there is
    /// a stalemate. If player 1 didn't win with the move, then draw an available cell for player 2 (i.e, the computer)
    /// and then check for a win for player 2 (computer) or a stalemate
    /// - parameter recognizer: the gesture recognizer

    
    func handleTapGestureRecognizer(_ recognizer: UITapGestureRecognizer)
    {
        guard !gameOver() else { return }
        
        switch recognizer.state {
        case .ended:
            let tappedPoint = recognizer.location(in: collectionView)
            if let tappedCellPath = collectionView?.indexPathForItem(at: tappedPoint), let cell = collectionView?.cellForItem(at: tappedCellPath) as? TicTacToeViewCell {
                guard !cell.marked else { return }
                
                cell.mark = .x
                tournament.game.player1PlaysPosition(tappedCellPath.item)
                if tournament.game.player1Won() {
                    updateTournamentWithWinner(.x)
                }
                else if tournament.game.player2Won() {
                    updateTournamentWithWinner(.o)
                }
                else if tournament.game.nobodyCanWin() {
                    updateTournamentWithWinner(nil)
                }
                else {
                    let nextPosition = tournament.game.nextMoveForPlayer2()
                    tournament.game.player2PlaysPosition(nextPosition)
                    let cellPath = IndexPath(item: nextPosition, section: 0)
                    if let player2Cell = collectionView?.cellForItem(at: cellPath) as? TicTacToeViewCell {
                        player2Cell.mark = .o
                    }                    
                    if tournament.game.player2Won() {
                        updateTournamentWithWinner(.o)
                    }
                    else if tournament.game.nobodyCanWin() {
                        updateTournamentWithWinner(nil)
                    }
                }
            }
        default: break
        }
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func pressedResetButton(_ sender: UIButton)
    {
        tournament.newGame()
        
        for i in 0..<tournament.game.numberOfPositions {
            let path = IndexPath(item: i, section: 0)
            if let cell = collectionView?.cellForItem(at: path) as? TicTacToeViewCell {
                cell.mark = nil
                cell.isInWinningPath = false
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tournament.game.numberOfPositions
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        var reuseView = UICollectionReusableView()
        if kind == UICollectionElementKindSectionFooter {
            gameFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: StoryBoard.footerReuseIdentifier, for: indexPath) as! TicTacToeFooterView
            reuseView = gameFooterView
        }
        
        return reuseView
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryBoard.cellReuseIdentifier, for: indexPath) as! TicTacToeViewCell

        return cell
    }
    
    

    // MARK: UICollectionViewDelegateFlowLayout
    
    /// Return a CGSize for the collectionView footer view based on available space (i.e., space not taken up by the cells)
    /// in the collectionView.
    /// - returns CGSize
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let availableWidth = (collectionView.bounds.width - 2.0*(layout.minimumInteritemSpacing + layout.sectionInset.left + layout.sectionInset.right))
        let availableHeight = collectionView.bounds.height - (2.0*layout.minimumLineSpacing + layout.sectionInset.top + layout.sectionInset.bottom + availableWidth + StoryBoard.navBarSpacing)
        return CGSize(width: availableWidth, height: availableHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let availableWidth = (collectionView.bounds.width - 2.0*(layout.minimumInteritemSpacing + layout.sectionInset.left + layout.sectionInset.right))
        return CGSize(width: availableWidth/CGFloat(StoryBoard.cellsPerRow), height: availableWidth/CGFloat(StoryBoard.cellsPerRow))
    }
    
    
    //MARK: - Private
    
    fileprivate func updateTournamentWithWinner(_ winner: BoardMark?)
    {
        if let winner = winner {
            switch winner {
            case .x:
                tournament.gamesWonByX += 1
            case .o:
                tournament.gamesWonByO += 1
            }
        }
        tournament.gamesPlayed += 1
        showStats()
    }
    
    fileprivate func gameOver() -> Bool
    {
        return tournament.game.player1Won() || tournament.game.player2Won() || tournament.game.nobodyCanWin()
    }
    
    fileprivate func markWinningPositions()
    {
        let positions = tournament.game.winningCells()
        for position in positions {
            let indexPath = IndexPath(item: position, section: 0)
            if let cell = collectionView?.cellForItem(at: indexPath) as? TicTacToeViewCell {
                cell.isInWinningPath = true
            }
        }
    }
    
    fileprivate func showStats()
    {
        var message: String = ""
        if tournament.game.player1Won() {
            message = AlertMessage.youWin
            markWinningPositions()
        }
        else if tournament.game.player2Won() {
            message = AlertMessage.youLoose
            markWinningPositions()
        }
        else if tournament.game.nobodyCanWin() {
            message = AlertMessage.nobodyWins
        }

        let alert = UIAlertController(
            title: AlertMessage.title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: AlertMessage.ok,
            style: UIAlertActionStyle.cancel,
            handler: { (action) in

        }))
     
        gameFooterView.updateStatsForGame(tournament)

        self.present(alert, animated: true, completion: nil)
    }

}
