//
//  ViewController.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/18/15.
//
//

import UIKit

class GameViewController: UIViewController {
    
    var gameEngine = T3GameEngine()
    
    // views
    var gameView = GameView(frame: CGRectZero)
    
    // views bucket
    var viewsBucket = [String:UIView]()
    
    // holder vars for game state data
    var currentPlayer = Player.O
    var currentGameState: GameState? {
        didSet {
            currentPlayer = currentPlayer.getOpponent()
            gameView.gameState = self.currentGameState
        }
    }
    
    var isGameFinished = false
    var lastPlay: PlayResult? {
        didSet {
            
            self.currentGameState = self.lastPlay?.gameState
            
            if self.lastPlay?.gameComplete == true {
                isGameFinished = true
                doFinishedGame()
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        
        gameView.viewDelegate = self
        gameView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(gameView)
        
        // apply constraints
        viewsBucket["gameView"] = gameView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[gameView]-20-|", options: nil, metrics: nil, views: viewsBucket))
        self.view.addConstraint(NSLayoutConstraint(item: gameView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: gameView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: gameView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        
        // add in draw view, but make it hidden
        let drawView = UILabel()
        drawView.text = "Game is a Draw"
        drawView.textColor = UIColor.whiteColor()
        drawView.textAlignment = NSTextAlignment.Center
        drawView.setTranslatesAutoresizingMaskIntoConstraints(false)
        drawView.alpha = 0.0
        self.view.addSubview(drawView)
        
        
        viewsBucket["drawView"] = drawView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[drawView]-20-|", options: nil, metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[gameView]-[drawView(==30)]", options: nil, metrics: nil, views: viewsBucket))
        
        currentGameState = GameState()
        computerPlaysMove()
        
        // tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDidTapGameView:"))
        self.view.addGestureRecognizer(tapRecognizer)
    }

    func userDidTapGameView(touch: UIEvent) {
//        println("Received touch: \(touch)")
        computerPlaysMove()
    }
    
    func computerPlaysMove() {
        if !isGameFinished {
            lastPlay = gameEngine.playNextMove(currentGameState!, asPlayer: currentPlayer)
        }
        // else ignore move
    }
    
    func doFinishedGame() {
        println("Game is finished.")
        if lastPlay?.winningPlayer != nil {
            // show winning player
        } else {
            doShowDraw()
        }
    }
    
    func doShowDraw() {
        if let view = viewsBucket["drawView"] {
           view.alpha = 1.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

