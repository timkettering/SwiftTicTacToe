//
//  GameView.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/18/15.
//
//

import UIKit

class GameSquareView: UIView {
    
    var gameSquarePos: GameSquarePos
    var player: Player?
    var viewLabel = UILabel()
    weak var delegate: GameView?
    
    init(squarePos: GameSquarePos, player: Player?) {

        self.gameSquarePos = squarePos
        self.player = player
        
        // some sort of default
        super.init(frame: CGRectMake(0, 0, 100, 100))
        
        renderGameSquare()
        updatePlayerSymbol()
        
        // tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDidTapGameSquare:"))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePlayerSymbol() {

        var oldValue = viewLabel.text
        
        if let p = player {
            
            if p == .X && oldValue == "" {
                viewLabel.text = Player.X.description
                self.animatePlayerSymbolBeingPlaced()
            } else if p == .O && oldValue == "" {
                viewLabel.text = Player.O.description
                self.animatePlayerSymbolBeingPlaced()
            }
            
        } else {
            // clear label state and hide it
            viewLabel.text = ""
            viewLabel.textColor = UIColor.whiteColor()
        }
    }
    
    func animatePlayerSymbolBeingPlaced() {
        
        let origTransformIdentity = viewLabel.transform
        viewLabel.alpha = 0.1
        
        self.viewLabel.transform = CGAffineTransformMakeScale(1.5, 1.5)
        UIView.animateKeyframesWithDuration(0.25, delay: 0.0, options: (UIViewKeyframeAnimationOptions.CalculationModeCubicPaced), animations: { () -> Void in
            
            self.viewLabel.transform = CGAffineTransformMakeScale(0.9, 0.9)
            self.viewLabel.alpha = 1.0
            }) { (success) -> Void in
                self.viewLabel.transform = origTransformIdentity
        }
    }
    
    func animateWinningSquare(completion: (Bool) -> Void) {
        
        let origTransformIdentity = viewLabel.transform
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
            self.viewLabel.transform = CGAffineTransformMakeScale(1.5, 1.5)
            self.viewLabel.textColor = UIColor.greenColor()
        }) { (success) -> Void in
            self.viewLabel.transform = origTransformIdentity
            completion(true)
        }
    }
    
    func renderGameSquare() {
        
        viewLabel = UILabel(frame: CGRectMake(0, 0, 50, 50))
        viewLabel.font = UIFont(name: ApplicationAppearance.AppFont.rawValue, size: 60.0)
        viewLabel.textColor = UIColor.whiteColor()
        viewLabel.sizeToFit()
        viewLabel.textAlignment = NSTextAlignment.Center
        viewLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(viewLabel)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view":viewLabel]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view":viewLabel]))
    }
    
    func userDidTapGameSquare(touch: UITouch) {
        delegate?.userDidTapGameSquare(self.gameSquarePos)
    }
}

class GameView: UIView {
    
    // game view constants
    let GRID_LINE_WIDTH: CGFloat = 8.0
    
    // view delegate
    weak var viewDelegate: GameViewController?
    
    var squareViews = [GameSquareView]()
    var gridDrawn = false
    var gameState: GameState? {
        didSet {
            self.updateGameViewToNewGameState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        self.drawGameSquares()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        self.drawGameGrid()
    }
    
    func getGridIncrement(length: CGFloat, parts: Int, multiplier: Int) -> CGFloat {
        
        let val:CGFloat = CGFloat(multiplier) / CGFloat(parts)
        return val * length
    }
    
    func userDidTapGameSquare(pos: GameSquarePos) {
        viewDelegate?.userDidTapGameSquare(pos);
    }
    
    func drawGameGrid() {
        
        if gridDrawn {
            return
        }
        
        let rectHeight = CGRectGetHeight(self.frame)
        let rectWidth = CGRectGetWidth(self.frame)
        
        // draw line 1
        let line1 = UIBezierPath()
        line1.moveToPoint(CGPointMake(0, getGridIncrement(rectHeight, parts: 3, multiplier: 1)))
        line1.addLineToPoint(CGPointMake(rectWidth, getGridIncrement(rectHeight, parts: 3, multiplier: 1)))
        line1.closePath()
        line1.lineWidth = GRID_LINE_WIDTH
        UIColor.whiteColor().setStroke()
        line1.stroke()
        
        // draw line 2
        let line2 = UIBezierPath()
        line2.moveToPoint(CGPointMake(0, getGridIncrement(rectWidth, parts: 3, multiplier: 2)))
        line2.addLineToPoint(CGPointMake(rectWidth, getGridIncrement(rectWidth, parts: 3, multiplier: 2)))
        line2.closePath()
        line2.lineWidth = GRID_LINE_WIDTH
        UIColor.whiteColor().setStroke()
        line2.stroke()
        
        // draw line 3
        let line3 = UIBezierPath()
        line3.moveToPoint(CGPointMake(getGridIncrement(rectWidth, parts: 3, multiplier: 1), 0))
        line3.addLineToPoint(CGPointMake(getGridIncrement(rectWidth, parts: 3, multiplier: 1), rectHeight))
        line3.closePath()
        line3.lineWidth = GRID_LINE_WIDTH
        UIColor.whiteColor().setStroke()
        line3.stroke()
        
        // draw line 4
        let line4 = UIBezierPath()
        line4.moveToPoint(CGPointMake(getGridIncrement(rectWidth, parts: 3, multiplier: 2), 0))
        line4.addLineToPoint(CGPointMake(getGridIncrement(rectWidth, parts: 3, multiplier: 2), rectHeight))
        line4.closePath()
        line4.lineWidth = GRID_LINE_WIDTH
        UIColor.whiteColor().setStroke()
        line4.stroke()
        
        gridDrawn = true
    }
    
    func drawGameSquares() {
        
        for i in 0 ..< DEFAULT_GAMEBOARD_SQUARES {
            
            let pos = GameSquarePos.getGameSquareForArrayPos(i)
            let squareView = GameSquareView(squarePos: pos, player: nil)
            squareView.delegate = self
            squareView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            let widthMultiplier:CGFloat = CGFloat((pos.col * 2) + 1) / CGFloat(DEFAULT_GAMEBOARD_SIZE * 2)
            let heightMultiplier:CGFloat = CGFloat((pos.row * 2) + 1) / CGFloat(DEFAULT_GAMEBOARD_SIZE * 2)
            
            self.addSubview(squareView)
            
            // set constraints
            let centerXCons = NSLayoutConstraint(item: squareView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: widthMultiplier, constant: 0.0)
            let centerYCons = NSLayoutConstraint(item: squareView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: heightMultiplier, constant: 0.0)
            
            let widthCons = NSLayoutConstraint(item: squareView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 0.3, constant: 0.0)
            let heightCons = NSLayoutConstraint(item: squareView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 0.3, constant: 0.0)
            
            self.addConstraint(centerXCons)
            self.addConstraint(centerYCons)
            self.addConstraint(widthCons)
            self.addConstraint(heightCons)
            
            // add to array for tracking
            squareViews.insert(squareView, atIndex: i)
        }
        
    }
    
    func updateGameViewToNewGameState() {
        
        if let gameState = gameState {
        
            for i in 0 ..< DEFAULT_GAMEBOARD_SQUARES {
                
                let player = gameState.squares[i]
                let sqView = squareViews[i]
                
                sqView.player = player
                sqView.updatePlayerSymbol()
            }
        }
    }
    
    func animateWinningPositions(player: Player, positions: [GameSquarePos], completion: (Bool) -> Void) {
        
        var count = positions.count
        
        for pos in positions {
            let squareView = squareViews[GameSquarePos.getArrayPosForGameSquarePos(pos)]
            squareView.animateWinningSquare({ (success) -> Void in
                count--
                if count == 0 {
                    completion(true)
                }
            })
        }
    }
}
