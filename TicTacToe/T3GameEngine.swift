//
//  T3GameEngine.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/18/15.
//
//

import Foundation

let GAMEBOARD_SIZE: Int = 3

enum SquareState {
    case X
    case O
    case None
}

struct GameSquarePos {
    var row: Int
    var col: Int
}

class GameBoard {
    
    var squares = [SquareState](count: GAMEBOARD_SIZE * GAMEBOARD_SIZE, repeatedValue: SquareState.None)
    
    func isEmpty() -> Bool {
        for sq in squares {
            if sq != SquareState.None {
                return false
            }
        }
        return true
    }
    
    func setSquareState(pos: GameSquarePos, state: SquareState) {
        
        let loc = self.getArrayPosForGameSquarePos(pos, boardSize: GAMEBOARD_SIZE)
        squares[loc] = state
    }
    
    func getSquareState(pos: GameSquarePos) -> SquareState {
        
        let loc = self.getArrayPosForGameSquarePos(pos, boardSize: GAMEBOARD_SIZE)
        return squares[loc]
    }
    
    func getArrayPosForGameSquarePos(pos: GameSquarePos, boardSize: Int) -> Int {
        return (pos.col * boardSize) + pos.row
    }
}

/*
    The game engine for tic-tac-toe.  Responsible for determining the game moves
*/
class T3GameEngine {
    
    /*
        Returns a Gameboard object with the next move populated, or nil
        if the board is in an invalid state
    */
    func doNextMove(board: GameBoard) -> GameBoard? {
        
        if board.isEmpty() {
            // set gamepiece to center
            board.setSquareState(GameSquarePos(row: 1, col: 1), state: .X)
        }
        
        return board
    }
}