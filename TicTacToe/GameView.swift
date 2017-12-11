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
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        renderGameSquare()
        updatePlayerSymbol()
        
        // tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameSquareView.userDidTapGameSquare(_:)))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePlayerSymbol() {

        let oldValue = viewLabel.text
        
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
            viewLabel.textColor = UIColor.white
        }
    }
    
    func animatePlayerSymbolBeingPlaced() {
        
        let origTransformIdentity = viewLabel.transform
        viewLabel.alpha = 0.1
        
        self.viewLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        UIView.animateKeyframes(withDuration: 0.25, delay: 0.0, options: (UIViewKeyframeAnimationOptions.calculationModeCubicPaced), animations: { () -> Void in
            
            self.viewLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.viewLabel.alpha = 1.0
            }) { (success) -> Void in
                self.viewLabel.transform = origTransformIdentity
        }
    }
    
    func animateWinningSquare(_ completion: @escaping (Bool) -> Void) {
        
        let origTransformIdentity = viewLabel.transform
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
            self.viewLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.viewLabel.textColor = UIColor.green
        }) { (success) -> Void in
            self.viewLabel.transform = origTransformIdentity
            completion(true)
        }
    }
    
    func renderGameSquare() {
        
        viewLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        viewLabel.font = UIFont(name: ApplicationAppearance.AppFont.rawValue, size: 60.0)
        viewLabel.textColor = UIColor.white
        viewLabel.sizeToFit()
        viewLabel.textAlignment = NSTextAlignment.center
        viewLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(viewLabel)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":viewLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":viewLabel]))
    }
    
    @objc func userDidTapGameSquare(_ touch: UITouch) {
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
        self.backgroundColor = UIColor.clear
        
        self.drawGameSquares()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        self.drawGameGrid()
    }
    
    func getGridIncrement(_ length: CGFloat, parts: Int, multiplier: Int) -> CGFloat {
        
        let val:CGFloat = CGFloat(multiplier) / CGFloat(parts)
        return val * length
    }
    
    func userDidTapGameSquare(_ pos: GameSquarePos) {
        viewDelegate?.userDidTapGameSquare(pos);
    }
    
    func drawGameGrid() {
        
        if gridDrawn {
            return
        }
        
        let rectHeight = self.frame.height
        let rectWidth = self.frame.width
        
        // draw line 1
        let line1 = UIBezierPath()
        line1.move(to: CGPoint(x: 0, y: getGridIncrement(rectHeight, parts: 3, multiplier: 1)))
        line1.addLine(to: CGPoint(x: rectWidth, y: getGridIncrement(rectHeight, parts: 3, multiplier: 1)))
        line1.close()
        line1.lineWidth = GRID_LINE_WIDTH
        UIColor.white.setStroke()
        line1.stroke()
        
        // draw line 2
        let line2 = UIBezierPath()
        line2.move(to: CGPoint(x: 0, y: getGridIncrement(rectWidth, parts: 3, multiplier: 2)))
        line2.addLine(to: CGPoint(x: rectWidth, y: getGridIncrement(rectWidth, parts: 3, multiplier: 2)))
        line2.close()
        line2.lineWidth = GRID_LINE_WIDTH
        UIColor.white.setStroke()
        line2.stroke()
        
        // draw line 3
        let line3 = UIBezierPath()
        line3.move(to: CGPoint(x: getGridIncrement(rectWidth, parts: 3, multiplier: 1), y: 0))
        line3.addLine(to: CGPoint(x: getGridIncrement(rectWidth, parts: 3, multiplier: 1), y: rectHeight))
        line3.close()
        line3.lineWidth = GRID_LINE_WIDTH
        UIColor.white.setStroke()
        line3.stroke()
        
        // draw line 4
        let line4 = UIBezierPath()
        line4.move(to: CGPoint(x: getGridIncrement(rectWidth, parts: 3, multiplier: 2), y: 0))
        line4.addLine(to: CGPoint(x: getGridIncrement(rectWidth, parts: 3, multiplier: 2), y: rectHeight))
        line4.close()
        line4.lineWidth = GRID_LINE_WIDTH
        UIColor.white.setStroke()
        line4.stroke()
        
        gridDrawn = true
    }
    
    func drawGameSquares() {
        
        for i in 0 ..< DEFAULT_GAMEBOARD_SQUARES {
            
            let pos = GameSquarePos.getGameSquareForArrayPos(i)
            let squareView = GameSquareView(squarePos: pos, player: nil)
            squareView.delegate = self
            squareView.translatesAutoresizingMaskIntoConstraints = false
            
            let widthMultiplier:CGFloat = CGFloat((pos.col * 2) + 1) / CGFloat(DEFAULT_GAMEBOARD_SIZE * 2)
            let heightMultiplier:CGFloat = CGFloat((pos.row * 2) + 1) / CGFloat(DEFAULT_GAMEBOARD_SIZE * 2)
            
            self.addSubview(squareView)
            
            // set constraints
            let centerXCons = NSLayoutConstraint(item: squareView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: widthMultiplier, constant: 0.0)
            let centerYCons = NSLayoutConstraint(item: squareView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: heightMultiplier, constant: 0.0)
            
            let widthCons = NSLayoutConstraint(item: squareView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.3, constant: 0.0)
            let heightCons = NSLayoutConstraint(item: squareView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0.3, constant: 0.0)
            
            self.addConstraint(centerXCons)
            self.addConstraint(centerYCons)
            self.addConstraint(widthCons)
            self.addConstraint(heightCons)
            
            // add to array for tracking
            squareViews.insert(squareView, at: i)
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
    
    func animateWinningPositions(_ player: Player, positions: [GameSquarePos], completion: @escaping (Bool) -> Void) {
        
        var count = positions.count
        
        for pos in positions {
            let squareView = squareViews[GameSquarePos.getArrayPosForGameSquarePos(pos)]
            squareView.animateWinningSquare({ (success) -> Void in
                count = count - 1
                if count == 0 {
                    completion(true)
                }
            })
        }
    }
}
