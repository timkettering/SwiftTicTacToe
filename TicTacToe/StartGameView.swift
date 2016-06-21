//
//  StartGameView.swift
//  TicTacToe
//
//  Created by Tim Kettering on 7/6/15.
//
//

import UIKit

class StartGameView: UIView {
    
    let LIGHT_YELLOW = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 102.0/255.0, alpha: 1.0)
    
    var topic: String? {
        didSet {
            titleLabel.text = self.topic
        }
    }
    
    var titleLabel = UILabel()
    var messageLabel = UILabel()
    
    var computerFirstBtn = UIButton(type: UIButtonType.System)
    var playerFirstBtn = UIButton(type: UIButtonType.System)
    
    var viewsBucket = [String:UIView]()
    
    weak var delegate: GameViewController?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.blackColor()
        containerView.alpha = 0.8
        self.addSubview(containerView)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-150-[containerView]-150-|", options: [], metrics: nil, views: ["containerView": containerView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[containerView]-30-|", options: [], metrics: nil, views: ["containerView": containerView]))
        
        // draw labels
        titleLabel.text = topic
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: ApplicationAppearance.AppFont.rawValue, size: 33.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        viewsBucket["titleLabel"] = titleLabel
        
        computerFirstBtn.setTitle("Computer Plays First", forState: UIControlState.Normal)
        computerFirstBtn.titleLabel?.font = UIFont(name: ApplicationAppearance.AppFont.rawValue, size: 24.0)
        computerFirstBtn.setTitleColor(LIGHT_YELLOW, forState: UIControlState.Normal)
        computerFirstBtn.addTarget(self, action: #selector(StartGameView.userWantsComputerToGoFirst), forControlEvents: UIControlEvents.TouchUpInside)
        computerFirstBtn.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(computerFirstBtn)
        
        viewsBucket["computerFirstBtn"] = computerFirstBtn
        
        playerFirstBtn.setTitle("Player Plays First", forState: UIControlState.Normal)
        playerFirstBtn.titleLabel?.font = UIFont(name: ApplicationAppearance.AppFont.rawValue, size: 24.0)
        playerFirstBtn.setTitleColor(LIGHT_YELLOW, forState: UIControlState.Normal)
        playerFirstBtn.addTarget(self, action: #selector(StartGameView.userWantsToGoFirst), forControlEvents: UIControlEvents.TouchUpInside)
        playerFirstBtn.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(playerFirstBtn)
        
        viewsBucket["playerFirstBtn"] = playerFirstBtn
        
        // do layout
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-|", options: [], metrics: nil, views: viewsBucket))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[computerFirstBtn]-|", options: [], metrics: nil, views: viewsBucket))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[playerFirstBtn]-|", options: [], metrics: nil, views: viewsBucket))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]", options: [], metrics: nil, views: viewsBucket))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[computerFirstBtn]-15-[playerFirstBtn]-|", options: [], metrics: nil, views: viewsBucket))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Button Target Events
    func userWantsComputerToGoFirst() {
        self.startNewGameWith(false)
    }
    
    func userWantsToGoFirst() {
        self.startNewGameWith(true)
    }
    
    // MARK: Delegate Methods
    func startNewGameWith(playerGoesFirst: Bool) {
        delegate?.startNewGame(playerGoesFirst)
    }
}
