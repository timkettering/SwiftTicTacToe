//
//  ViewController.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/18/15.
//
//

import UIKit

enum ApplicationAppearance: String {
    case AppFont = "ShadowsIntoLight"
}

class GameViewController: UIViewController {
    
    let QUICK_ANIM_DUR = 0.25
    let SLOW_ANIM_DUR = 0.5
    let MESSAGE_FONT = UIFont(name: ApplicationAppearance.AppFont.rawValue, size: 22.0)
    
    var computerPlays = Player.X
    
    var gameEngine = T3GameEngine()
    
    // views
    var gameView = GameView(frame: CGRectZero)
    var startGameView = StartGameView(frame: CGRectZero)
    var yourPlayView = UILabel()
    var imThinkingView = UILabel()
    var newGame = UIButton()
    
    // views bucket
    var viewsBucket = [String:UIView]()
    
    // holder vars for game state data
    var currentPlayer = Player.X {
        didSet {
            if self.currentPlayer != computerPlays {
                self.showYourPlayView(true)
            } else {
                self.showYourPlayView(false)
            }
        }
    }
    
    var currentGameState: GameState? {
        didSet {
            currentPlayer = currentPlayer.getOpponent()
            gameView.gameState = self.currentGameState
        }
    }
    
    var isGameFinished = false
    var lastPlay: PlayResult? {
        didSet {
            if let lp = self.lastPlay {
                self.currentGameState = self.lastPlay?.gameState
                
                if self.lastPlay?.gameComplete == true {
                    isGameFinished = true
                    doFinishedGame()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.orangeColor()
        
        // background image
        let backgroundView = UIImageView(image: UIImage(named: "background.jpg"))
        backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(backgroundView)
        
        viewsBucket["backgroundView"] = backgroundView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundView]|", options: nil, metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundView]|", options: nil, metrics: nil, views: viewsBucket))
        
        // game view
        gameView.viewDelegate = self
        gameView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(gameView)
        
        // apply constraints
        viewsBucket["gameView"] = gameView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[gameView]-20-|", options: nil, metrics: nil, views: viewsBucket))
        self.view.addConstraint(NSLayoutConstraint(item: gameView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: gameView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: gameView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        
        // add in restart game view, make hidden too
        newGame.setTranslatesAutoresizingMaskIntoConstraints(false)
        newGame.setTitle("New Game", forState: UIControlState.Normal)
        newGame.titleLabel?.font = MESSAGE_FONT
        newGame.addTarget(self, action: Selector("showStartGameView"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(newGame)
        
        viewsBucket["newGame"] = newGame
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[newGame]-20-|", options: nil, metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[gameView]-40-[newGame(==30)]", options: nil, metrics: nil, views: viewsBucket))
        
        // your play view
        yourPlayView.text = "I await your play..."
        yourPlayView.font = MESSAGE_FONT
        yourPlayView.textColor = UIColor.whiteColor()
        yourPlayView.setTranslatesAutoresizingMaskIntoConstraints(false)
        yourPlayView.alpha = 0.0
        self.view.addSubview(yourPlayView)
        
        viewsBucket["yourPlayView"] = yourPlayView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[yourPlayView]", options: nil, metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[yourPlayView]-20-[gameView]", options: nil, metrics: nil, views: viewsBucket))
        
        // im thinking view
        imThinkingView.text = "I'm thinking!"
        imThinkingView.font = MESSAGE_FONT
        imThinkingView.textColor = UIColor.whiteColor()
        imThinkingView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imThinkingView.textAlignment = NSTextAlignment.Right
        imThinkingView.alpha = 0.0
        self.view.addSubview(imThinkingView)
        
        viewsBucket["imThinkingView"] = imThinkingView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imThinkingView]-20-|", options: nil, metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imThinkingView]-20-[gameView]", options: nil, metrics: nil, views: viewsBucket))
        
        
        // start game view
        startGameView.setTranslatesAutoresizingMaskIntoConstraints(false)
        startGameView.delegate = self
        startGameView.alpha = 0.0
        self.view.addSubview(startGameView)
        
        viewsBucket["startGameView"] = startGameView
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[startGameView]|", options: nil, metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[startGameView]|", options: nil, metrics: nil, views: viewsBucket))
        
        self.showGameElements(false)
        self.showStartGameView("Play A Game!")
    }

    func showYourPlayView(doShow: Bool) {
        

        UIView.animateWithDuration(QUICK_ANIM_DUR, animations: { () -> Void in
            
            if doShow {
                self.yourPlayView.alpha = 1.0
                self.imThinkingView.alpha = 0.0
            } else {
                self.yourPlayView.alpha = 0.0
                self.imThinkingView.alpha = 1.0
            }
            
        })
    }
    
    func animateWinningPositions(player: Player, positions: [GameSquarePos], completion: (Bool) -> Void) {
        
        self.gameView.animateWinningPositions(player, positions: positions) { (success) -> Void in
            completion(true)
        }
    }
    
    func showStartGameView() {
        showStartGameView("Start New Game")
    }
    
    func showStartGameView(topic: String?) {
        
        self.showGameElements(false)
        UIView.animateWithDuration(SLOW_ANIM_DUR, animations: { () -> Void in
            self.startGameView.topic = topic
            self.startGameView.alpha = 1.0
        }) { (finished) -> Void in
            self.resetGame()
        }
    }
    
    func startNewGame(playerGoesFirst: Bool) {
        
        if playerGoesFirst {
            self.computerPlays = Player.O
        } else {
            self.computerPlays = Player.X
        }
        
        currentPlayer = Player.X
        
        self.showGameElements(true)
        UIView.animateWithDuration(SLOW_ANIM_DUR, animations: { () -> Void in
            self.startGameView.alpha = 0.0
        }) { (finished) -> Void in
            if !playerGoesFirst {
               self.computerPlaysMove()
            }
        }
    }
    
    // MARK: Touch Up Events
    func userDidTapGameSquare(pos: GameSquarePos) {
        
        // first check if player is current player
        if currentPlayer == computerPlays.getOpponent() {
            if let cgs = currentGameState {
                if cgs.getPlayerForPosition(pos) == nil {
                    currentGameState = gameEngine.setSquare(cgs, pos: pos, asPlayer: computerPlays.getOpponent())
                    
                    if gameEngine.isGameFinished(currentGameState!) {
                        doFinishedGame()
                    } else {
                        computerPlaysMove()
                    }
                }
            }
        }
        
        // else ignore
    }
    
    func showGameElements(doShow: Bool) {
        
        yourPlayView.hidden = !doShow
        imThinkingView.hidden = !doShow
        gameView.hidden = !doShow
        newGame.hidden = !doShow
    }
    
    // MARK: Game events
    func resetGame() {
        currentGameState = GameState()
        currentPlayer = Player.X
        isGameFinished = false
        lastPlay = nil
    }
    
    func computerPlaysMove() {
        if !isGameFinished {
            
            // fake a bit of time to think
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.lastPlay = self.gameEngine.playNextMove(self.currentGameState!, asPlayer: self.currentPlayer)
            })
        }
        // else ignore move
    }
    
    func doFinishedGame() {
        
        if let winner = gameEngine.getWinner(currentGameState!) {
            
            self.imThinkingView.hidden = true
            self.yourPlayView.hidden = true
            
            animateWinningPositions(winner.0, positions: winner.1, completion: { (success) -> Void in
                // take a sec or two to rub defeat in the face of user
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    
                    self.showStartGameView("You Lose!")
                })
                
            })
        } else {
            self.showStartGameView("Game Tied!")
        }
    }
    
    // system functions
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

