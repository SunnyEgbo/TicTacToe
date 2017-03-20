//
//  TicTacToeViewCell.swift
//  TicTacToe
//
//  Created by Sunny Egbo on 5/23/16.
//  Copyright © 2016 Unatezesoft, LLC. All rights reserved.
//
// Abstract:
// Contains the TicTacToeViewCell which implements a collectionViewCell subclass.
//

import UIKit

class TicTacToeViewCell: UICollectionViewCell
{
 
    //MARK: Public vars

    var mark: Player? = nil {
        didSet {
            markView?.mark = mark
            setNeedsDisplay()
        }
    }
    var marked: Bool {
        return mark != .none
    }
    
    var isInWinningPath = false {
        didSet {
            if isInWinningPath {
                self.alpha = 0.65
            }
            else {
                self.alpha = 1.0
            }
        }
    }
    
    //MARK: Private vars
    
    @IBOutlet weak fileprivate var markView: MarkView! {
        didSet {
            markView.mark = mark
        }
    }
    
    
    //MARK: Public func
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.white
    }
        
    
    

    //MARK: Private func

    
}
