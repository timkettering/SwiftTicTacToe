//
//  TicTacToeTests.swift
//  TicTacToeTests
//
//  Created by Tim Kettering on 6/18/15.
//
//

import UIKit
import XCTest

class TicTacToeTests: XCTestCase {
    
    var gameEngine: T3GameEngine = T3GameEngine()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlayerEnum() {
        
        XCTAssertEqual(Player.O, Player.X.getOpponent(), "Opponent of Player O should be X.")
        XCTAssertEqual(Player.X, Player.O.getOpponent(), "Opponent of Player O should be X.")
    }
    
    func testGameState() {
        
        // instance gameboard
        let gs = GameState()
        
        XCTAssertEqual(DEFAULT_GAMEBOARD_SQUARES, gs.squares.count, "GameState should contain \(DEFAULT_GAMEBOARD_SQUARES) squares.")
        XCTAssertEqual(DEFAULT_GAMEBOARD_SQUARES, gs.unplayedPositions.count, "GameState should be unplayed.")
        
        // set a square
        XCTAssertEqual(0, gs.xPositions.count, "Player X should have zero positions")
        XCTAssertEqual(0, gs.oPositions.count, "Player O should have zero positions")
        XCTAssertTrue(gameEngine.isValidGameState(gs), "GameState should be valid.")
        
        let gs2 = gameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 1), asPlayer: Player.X)
        XCTAssertEqual(1, gs2.xPositions.count, "Player X should have one position")
        XCTAssertEqual(0, gs2.oPositions.count, "Player O should have zero positions")
        XCTAssertTrue(gameEngine.isValidGameState(gs2), "GameState should be valid.")
        
        // attempt illegal move
        let gs3 = gameEngine.setSquare(gs2, pos: GameSquarePos(row: 0, col: 2), asPlayer: Player.X)
        XCTAssertFalse(gameEngine.isValidGameState(gs3), "GameState should be invalid.")
    }
    
    func testPlayManyGames() {
        
        // play game with game engine as both players.  if functionality is correct,
        // all games should always end in a draw.  value is set to 10 to allow for quicker 
        // test run but a large number should be tested 
        for i in 0 ..< 10 {
            var gs = GameState()
            var player = Player.X
            while true {
                let result = gameEngine.playNextMove(gs, asPlayer: player)
                if result.gameComplete {
                    XCTAssertTrue(result.winningPlayer == nil, "A player has won the game! Should not happen.")
                    break
                } else {
                    gs = result.gameState!
                    player = player.getOpponent()
                }
            }
        }
    }
    
    func testMinmaxScores() {
    
        var gs = GameState()
        gs = gameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 0), asPlayer: Player.X)
        gs = gameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 1), asPlayer: Player.O)
        gs = gameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 2), asPlayer: Player.X)
        gs = gameEngine.setSquare(gs, pos: GameSquarePos(row: 1, col: 0), asPlayer: Player.O)
        gs = gameEngine.setSquare(gs, pos: GameSquarePos(row: 1, col: 1), asPlayer: Player.X)
        gs = gameEngine.setSquare(gs, pos: GameSquarePos(row: 1, col: 2), asPlayer: Player.O)
        gs = gameEngine.setSquare(gs, pos: GameSquarePos(row: 2, col: 0), asPlayer: Player.X)

        
        XCTAssertTrue(gameEngine.isValidGameState(gs), "Board should be in valid state")
        XCTAssertTrue(gameEngine.isGameFinished(gs), "Board should be in finished state")
        
        if let winner = gameEngine.getWinner(gs) {
            XCTAssertEqual(Player.X, winner.0, "Winner should be Player X")
        } else {
            XCTFail("Winner should have been determined.")
        }
        
        XCTAssertEqual(10, gameEngine.scoreForPlayer(gs, asPlayer: Player.X), "Player X score should be 10")
        XCTAssertEqual(-10, gameEngine.scoreForPlayer(gs, asPlayer: Player.O), "Player X score should be -10")
    }
    
    func testMinMaxPerformance() {
        
        var gs = GameState()
        gs = gameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 0), asPlayer: Player.X)
        
        var playResult = gameEngine.playNextMove(gs, asPlayer: Player.O)
    }
}
