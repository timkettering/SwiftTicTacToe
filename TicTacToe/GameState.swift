//
//  GameBoard.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/24/15.
//
//

import Foundation

// for application design simplicity, we'll hardcode defaults 
// for the tic-tac-toe game instance
let DEFAULT_GAMEBOARD_SIZE: Int = 3
let DEFAULT_GAMEBOARD_SQUARES: Int = DEFAULT_GAMEBOARD_SIZE * DEFAULT_GAMEBOARD_SIZE
let LEGAL_WINNING_LINES = (DEFAULT_GAMEBOARD_SIZE * 2) + 2

enum Player: Printable {
    case X
    case O
    func getOpponent() -> Player {
        return (self == Player.X) ? Player.O : Player.X
    }
    var description: String {
        return (self == Player.X) ? "X" : "O"
    }
}

struct GameSquarePos {
    var row: Int
    var col: Int
    static func getArrayPosForGameSquarePos(pos: GameSquarePos) -> Int {
        return (pos.row * DEFAULT_GAMEBOARD_SIZE) + pos.col
    }
    static func getGameSquareForArrayPos(pos: Int) -> GameSquarePos {
        let row = pos / DEFAULT_GAMEBOARD_SIZE
        let col = pos % DEFAULT_GAMEBOARD_SIZE
        return GameSquarePos(row: row, col: col)
    }
}

struct GameState: Printable {
    var squares = [Player?](count: DEFAULT_GAMEBOARD_SQUARES, repeatedValue: nil)
    var unplayedPositions: [GameSquarePos] {
        get {
            var unplayedPositions = [GameSquarePos]()
            for i in 0 ..< DEFAULT_GAMEBOARD_SQUARES {
                if squares[i] == nil {
                    unplayedPositions.append(GameSquarePos.getGameSquareForArrayPos(i))
                }
            }
            return unplayedPositions
        }
    }
    
    func getPlayerForPosition(gameSquarePos: GameSquarePos) -> Player? {
        return squares[GameSquarePos.getArrayPosForGameSquarePos(gameSquarePos)]
    }
    
    func getPlayerPositions(player: Player) -> [GameSquarePos] {
        var playerPositions = [GameSquarePos]()
        for i in 0 ..< DEFAULT_GAMEBOARD_SQUARES {
            if squares[i] == player {
                playerPositions.append(GameSquarePos.getGameSquareForArrayPos(i))
            }
        }
        return playerPositions
    }
    
    var description: String {
        var desc = "\n"
        for i in 0 ..< DEFAULT_GAMEBOARD_SIZE {
            desc += "|"
            for j in 0 ..< DEFAULT_GAMEBOARD_SIZE {
                
                if j > 0 {
                    desc += ","
                }
                
                if let player = getPlayerForPosition(GameSquarePos(row: i, col: j)) {
                    desc += player.description
                } else {
                    desc += "_"
                }
            }
            desc += "|\n"
        }
        return desc
    }
}