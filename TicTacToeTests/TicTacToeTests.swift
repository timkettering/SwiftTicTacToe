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
        XCTAssertEqual(0, gs.getPlayerPositions(Player.X).count, "Player X should have zero positions")
        XCTAssertEqual(0, gs.getPlayerPositions(Player.O).count, "Player O should have zero positions")
        XCTAssertTrue(T3GameEngine.isValidGameState(gs), "GameState should be valid.")
        
        let gs2 = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 1), asPlayer: Player.X)
        XCTAssertEqual(1, gs2.getPlayerPositions(Player.X).count, "Player X should have one position")
        XCTAssertEqual(0, gs2.getPlayerPositions(Player.O).count, "Player O should have zero positions")
        XCTAssertTrue(T3GameEngine.isValidGameState(gs2), "GameState should be valid.")
        
        // attempt illegal move
        let gs3 = T3GameEngine.setSquare(gs2, pos: GameSquarePos(row: 0, col: 2), asPlayer: Player.X)
        XCTAssertFalse(T3GameEngine.isValidGameState(gs3), "GameState should be invalid.")
        println(gs3)
        
//        gb.playMove(GameSquarePos(row: 0, col: 1), asPlayer: Player.X)
//        gb.playMove(GameSquarePos(row: 0, col: 0), asPlayer: Player.O)
//        gb.playMove(GameSquarePos(row: 1, col: 1), asPlayer: Player.X)
//        gb.playMove(GameSquarePos(row: 0, col: 2), asPlayer: Player.O)
//        gb.playMove(GameSquarePos(row: 2, col: 1), asPlayer: Player.X)
        
//        XCTAssertFalse(gb.isUnplayed(), "Board state should now be not unplayed");
//        XCTAssertTrue(gb.isValidBoard(), "Board should be in valid state.")
        
//        XCTAssertTrue(gb.getSquareState(GameSquarePos(row: 0, col: 1)) == Player.X, "State of square is not Player X")
//        XCTAssertTrue(gb.getSquareState(GameSquarePos(row: 2, col: 2)) == nil, "This square should be empty.")
        
//        if let winner = gb.getWinner() {
//        
//        } else {
//            XCTFail("Winner is nil.")
//        }
    }
    
    func testPlayManyGames() {
        
        for i in 0 ..< 10 {
            println("Starting game #\(i).")
            var gs = GameState()
            var player = Player.X
            while true {
                let result = T3GameEngine.playNextMove(gs, asPlayer: player)
                println("Player \(player.description) completed move.")
                if result.gameComplete {
                    println("Game concluded in: \(result.winningPlayer)")
                    break
                } else {
                    gs = result.gameState!
                    player = player.getOpponent()
                }
            }
        }
    }
    
    func testPlayGame() {
        
        var gs = GameState()
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 2, col: 0), asPlayer: Player.X)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 1, col: 1), asPlayer: Player.O)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 2, col: 1), asPlayer: Player.X)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 0), asPlayer: Player.O)
//        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 2, col: 2), asPlayer: Player.X)
        

        var playResult = T3GameEngine.playNextMove(gs, asPlayer: Player.X)
        println("Play Result: Game is finished: \(playResult.gameComplete), winner is: \(playResult.winningPlayer), \(playResult.gameState)")
    }
    
    func testMinmaxScores() {
    
        var gs = GameState()
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 0), asPlayer: Player.X)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 1), asPlayer: Player.O)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 0, col: 2), asPlayer: Player.X)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 1, col: 0), asPlayer: Player.O)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 1, col: 1), asPlayer: Player.X)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 1, col: 2), asPlayer: Player.O)
        gs = T3GameEngine.setSquare(gs, pos: GameSquarePos(row: 2, col: 0), asPlayer: Player.X)

        
        XCTAssertTrue(T3GameEngine.isValidGameState(gs), "Board should be in valid state")
        XCTAssertTrue(T3GameEngine.isGameFinished(gs), "Board should be in finished state")
        
        if let winner = T3GameEngine.getWinner(gs) {
            XCTAssertEqual(Player.X, winner.0, "Winner should be Player X")
        } else {
            XCTFail("Winner should have been determined.")
        }
        
        println(gs)
        XCTAssertEqual(10, T3GameEngine.scoreForPlayer(gs, asPlayer: Player.X), "Player X score should be 10")
        XCTAssertEqual(-10, T3GameEngine.scoreForPlayer(gs, asPlayer: Player.O), "Player X score should be -10")
    }
    
    func testMinMaxMove() {
        
//        var gb = GameState()
//        
//        T3GameEngine.playNextMove(gb, asPlayer: Player.X)
//        T3GameEngine.playNextMove(gb, asPlayer: Player.O)
    }
}
