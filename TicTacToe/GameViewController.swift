//
//  ViewController.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/18/15.
//
//

import UIKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        
        let gameView = GameView(frame: CGRectZero)
        gameView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(gameView)
        
        // apply constraints
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[view]-20-|", options: nil, metrics: nil, views: ["view":gameView]))
        self.view.addConstraint(NSLayoutConstraint(item: gameView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: gameView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: gameView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        
        let gs = GameState()
//        T3GameEngine.playNextMove(gb, asPlayer: Player.X)
//        T3GameEngine.playNextMove(gb, asPlayer: Player.O)
//        T3GameEngine.playNextMove(gb, asPlayer: Player.X)
        gameView.gameState = gs
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

