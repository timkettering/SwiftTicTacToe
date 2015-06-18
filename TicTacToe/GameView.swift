//
//  GameView.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/18/15.
//
//

import UIKit

class GameView: UIView {
    
    let ONE_THIRD:CGFloat = 0.333
    let ONE_FOURTH:CGFloat = 0.25
    
    var squareViews = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        self.drawGameGrid()
        self.drawGameSquare(GameSquarePos(row: 0, col: 0), state: SquareState.X)
    }
    
    func getGridIncrement(length: CGFloat, parts: Int, multiplier: Int) -> CGFloat {
        
        let val:CGFloat = CGFloat(multiplier) / CGFloat(parts)
        return val * length
    }
    
    func drawGameGrid() {
        
        let rectHeight = CGRectGetHeight(self.frame)
        let rectWidth = CGRectGetWidth(self.frame)
        
        // draw line 1
        let line1 = UIBezierPath()
        line1.moveToPoint(CGPointMake(0, getGridIncrement(rectHeight, parts: 3, multiplier: 1)))
        line1.addLineToPoint(CGPointMake(rectWidth, getGridIncrement(rectHeight, parts: 3, multiplier: 1)))
        line1.closePath()
        line1.lineWidth = 10
        UIColor.whiteColor().setStroke()
        line1.stroke()
        
        // draw line 2
        let line2 = UIBezierPath()
        line2.moveToPoint(CGPointMake(0, getGridIncrement(rectWidth, parts: 3, multiplier: 2)))
        line2.addLineToPoint(CGPointMake(rectWidth, getGridIncrement(rectWidth, parts: 3, multiplier: 2)))
        line2.closePath()
        line2.lineWidth = 10
        UIColor.whiteColor().setStroke()
        line2.stroke()
        
        // draw line 3
        let line3 = UIBezierPath()
        line3.moveToPoint(CGPointMake(getGridIncrement(rectWidth, parts: 3, multiplier: 1), 0))
        line3.addLineToPoint(CGPointMake(getGridIncrement(rectWidth, parts: 3, multiplier: 1), rectHeight))
        line3.closePath()
        line3.lineWidth = 10
        UIColor.whiteColor().setStroke()
        line3.stroke()
        
        // draw line 4
        let line4 = UIBezierPath()
        line4.moveToPoint(CGPointMake(getGridIncrement(rectWidth, parts: 3, multiplier: 2), 0))
        line4.addLineToPoint(CGPointMake(getGridIncrement(rectWidth, parts: 3, multiplier: 2), rectHeight))
        line4.closePath()
        line4.lineWidth = 10
        UIColor.whiteColor().setStroke()
        line4.stroke()
    }
    

    
    func drawGameSquare(pos: GameSquarePos, state: SquareState) {
        
        let squareView = UILabel(frame: CGRectMake(0, 0, 50, 50))
        squareView.backgroundColor = UIColor.yellowColor()
        squareView.text = "X"
        
        let rectHeight = CGRectGetHeight(self.frame)
        let rectWidth = CGRectGetWidth(self.frame)
        
        squareView.center = CGPointMake(getGridIncrement(rectHeight, parts: 4, multiplier: pos.row + 1), getGridIncrement(rectWidth, parts: 4, multiplier: pos.col + 1))
        self.addSubview(squareView)
    }
}
