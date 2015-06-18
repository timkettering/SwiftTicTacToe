//
//  ViewController.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/18/15.
//
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let gameView = GameView(frame: CGRectMake(20, 50, 300, 300))
        self.view.addSubview(gameView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

