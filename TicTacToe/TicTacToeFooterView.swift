//
//  TicTacToeFooterView.swift
//  TicTacToe
//
//  Created by Sunny Egbo on 5/23/16.
//  Copyright © 2016 Unatezesoft, LLC. All rights reserved.
//
// Abstract:
// Contains the TicTacToeFooterView which displays tournament statistics.
//

import UIKit

class TicTacToeFooterView: UICollectionReusableView
{

    @IBOutlet fileprivate weak var gamesPlayedLabel: UILabel!
    @IBOutlet fileprivate weak var wonByXLabel: UILabel!
    @IBOutlet fileprivate weak var wonByOLabel: UILabel!
    
    
    func updateStatsForGame(_ tournament: Tournament)
    {
        gamesPlayedLabel.text = String(tournament.gamesPlayed)
        wonByXLabel.text = String(tournament.gamesWonByX)
        wonByOLabel.text = String(tournament.gamesWonByO)
    }
    
}
