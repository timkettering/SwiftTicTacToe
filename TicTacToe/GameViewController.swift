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
    case BackgroundImage = "background.jpg"
}


class GameViewController: UIViewController {
    
    let QUICK_ANIM_DUR = 0.25
    let SLOW_ANIM_DUR = 0.5
    let MESSAGE_FONT = UIFont(name: ApplicationAppearance.AppFont.rawValue, size: 22.0)

    let LIGHT_YELLOW = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 102.0/255.0, alpha: 1.0)
    
    var computerPlays = Player.X
    
    var gameEngine = T3GameEngine()
    
    // views
    var gameView = GameView(frame: CGRect.zero)
    var startGameView = StartGameView(frame: CGRect.zero)
    var yourPlayView = UILabel()
    var imThinkingView = UILabel()
    var newGame = UIButton(type: UIButton.ButtonType.system)
    
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
            if self.lastPlay != nil {
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
        let backgroundView = UIImageView(image: UIImage(named: ApplicationAppearance.BackgroundImage.rawValue))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundView)
        
        backgroundView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        // game view
        gameView.viewDelegate = self
        gameView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(gameView)
        
        // apply constraints
        viewsBucket["gameView"] = gameView
        gameView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        gameView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5).isActive = true
        gameView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        gameView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        // add in restart game view, make hidden too
        newGame.translatesAutoresizingMaskIntoConstraints = false
        newGame.setTitle("New Game", for: UIControl.State())
        newGame.titleLabel?.font = MESSAGE_FONT
        newGame.setTitleColor(LIGHT_YELLOW, for: UIControl.State())
        newGame.addTarget(self, action: #selector(GameViewController.showStartGameView as (GameViewController) -> () -> ()), for: UIControl.Event.touchUpInside)
        self.view.addSubview(newGame)
        
        viewsBucket["newGame"] = newGame
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[newGame]-20-|", options: [], metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[gameView]-40-[newGame(==30)]", options: [], metrics: nil, views: viewsBucket))
        
        // your play view
        yourPlayView.text = "I await your play..."
        yourPlayView.font = MESSAGE_FONT
        yourPlayView.textColor = UIColor.white
        yourPlayView.translatesAutoresizingMaskIntoConstraints = false
        yourPlayView.alpha = 0.0
        self.view.addSubview(yourPlayView)
        
        viewsBucket["yourPlayView"] = yourPlayView
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[yourPlayView]", options: [], metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[yourPlayView]-20-[gameView]", options: [], metrics: nil, views: viewsBucket))
        
        // im thinking view
        imThinkingView.text = "I'm thinking!"
        imThinkingView.font = MESSAGE_FONT
        imThinkingView.textColor = UIColor.white
        imThinkingView.translatesAutoresizingMaskIntoConstraints = false
        imThinkingView.textAlignment = NSTextAlignment.right
        imThinkingView.alpha = 0.0
        self.view.addSubview(imThinkingView)
        
        viewsBucket["imThinkingView"] = imThinkingView
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[imThinkingView]-20-|", options: [], metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imThinkingView]-20-[gameView]", options: [], metrics: nil, views: viewsBucket))
        
        // start game view
        startGameView.translatesAutoresizingMaskIntoConstraints = false
        startGameView.delegate = self
        startGameView.alpha = 0.0
        self.view.addSubview(startGameView)
        
        viewsBucket["startGameView"] = startGameView
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[startGameView]|", options: [], metrics: nil, views: viewsBucket))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[startGameView]|", options: [], metrics: nil, views: viewsBucket))
        
        self.showGameElements(false)
        self.showStartGameView("Play A Game!")
    }

    func showYourPlayView(_ doShow: Bool) {
        

        UIView.animate(withDuration: QUICK_ANIM_DUR, animations: { () -> Void in
            
            if doShow {
                self.yourPlayView.alpha = 1.0
                self.imThinkingView.alpha = 0.0
            } else {
                self.yourPlayView.alpha = 0.0
                self.imThinkingView.alpha = 1.0
            }
            
        })
    }
    
    func animateWinningPositions(_ player: Player, positions: [GameSquarePos], completion: @escaping (Bool) -> Void) {
        
        self.gameView.animateWinningPositions(player, positions: positions) { (success) -> Void in
            completion(true)
        }
    }
    
    @objc func showStartGameView() {
        showStartGameView("Start New Game")
    }
    
    func showStartGameView(_ topic: String?) {
        
        self.showGameElements(false)
        UIView.animate(withDuration: SLOW_ANIM_DUR, animations: { () -> Void in
            self.startGameView.topic = topic
            self.startGameView.alpha = 1.0
        }, completion: { (finished) -> Void in
            self.resetGame()
        }) 
    }
    
    func startNewGame(_ playerGoesFirst: Bool) {
        
        if playerGoesFirst {
            self.computerPlays = Player.O
        } else {
            self.computerPlays = Player.X
        }
        
        currentPlayer = Player.X
        
        
        UIView.animate(withDuration: SLOW_ANIM_DUR, animations: { () -> Void in
            self.startGameView.alpha = 0.0
        }, completion: { (finished) -> Void in
            
            self.showGameElements(true)
            
            if !playerGoesFirst {
                self.computerPlaysMove()
            }
        }) 
    }
    
    // MARK: Touch Up Events
    func userDidTapGameSquare(_ pos: GameSquarePos) {
        
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
    
    func showGameElements(_ doShow: Bool) {
        
        yourPlayView.isHidden = !doShow
        imThinkingView.isHidden = !doShow
        gameView.isHidden = !doShow
        newGame.isHidden = !doShow
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
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.lastPlay = self.gameEngine.playNextMove(self.currentGameState!, asPlayer: self.currentPlayer)
            })
        }
        // else ignore move
    }
    
    func doFinishedGame() {
        
        if let winner = gameEngine.getWinner(currentGameState!) {
            
            self.imThinkingView.isHidden = true
            self.yourPlayView.isHidden = true
            
            animateWinningPositions(winner.0, positions: winner.1, completion: { (success) -> Void in
                // take a sec or two to rub defeat in the face of user
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

