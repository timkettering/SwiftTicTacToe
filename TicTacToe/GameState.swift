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

enum Player: CustomStringConvertible {
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
    static func getArrayPosForGameSquarePos(_ pos: GameSquarePos) -> Int {
        return (pos.row * DEFAULT_GAMEBOARD_SIZE) + pos.col
    }
    static func getGameSquareForArrayPos(_ pos: Int) -> GameSquarePos {
        let row = pos / DEFAULT_GAMEBOARD_SIZE
        let col = pos % DEFAULT_GAMEBOARD_SIZE
        return GameSquarePos(row: row, col: col)
    }
}

struct GameState: CustomStringConvertible {
    let squares: [Player?]
    var unplayedPositions = [GameSquarePos]()
    var xPositions = [GameSquarePos]()
    var oPositions = [GameSquarePos]()
    var totalMoves = 0

    init() {
        squares = [Player?](repeating: nil, count: DEFAULT_GAMEBOARD_SQUARES)
        unplayedPositions = getUnplayedPositions()
        xPositions = getPlayerPositions(Player.X)
        oPositions = getPlayerPositions(Player.O)
        totalMoves = xPositions.count + oPositions.count
    }

    init(squares sq: [Player?]) {
        squares = sq
        unplayedPositions = getUnplayedPositions()
        xPositions = getPlayerPositions(Player.X)
        oPositions = getPlayerPositions(Player.O)
        totalMoves = xPositions.count + oPositions.count
    }

    fileprivate func getUnplayedPositions() -> [GameSquarePos] {
        var unplayedPositions = [GameSquarePos]()
        for i in 0 ..< DEFAULT_GAMEBOARD_SQUARES where squares[i] == nil {
            unplayedPositions.append(GameSquarePos.getGameSquareForArrayPos(i))
        }
        return unplayedPositions
    }

    func getPlayerForPosition(_ gameSquarePos: GameSquarePos) -> Player? {
        return squares[GameSquarePos.getArrayPosForGameSquarePos(gameSquarePos)]
    }

    fileprivate func getPlayerPositions(_ player: Player) -> [GameSquarePos] {
        var playerPositions = [GameSquarePos]()
        for i in 0 ..< DEFAULT_GAMEBOARD_SQUARES where squares[i] == player {
            playerPositions.append(GameSquarePos.getGameSquareForArrayPos(i))
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
