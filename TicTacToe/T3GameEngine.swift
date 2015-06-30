//
//  T3GameEngine.swift
//  TicTacToe
//
//  Created by Tim Kettering on 6/18/15.
//
//

import Foundation

enum GameScoring: Int {
    case PLAYER_WIN = 10
    case OPPONENT_WIN = -10
    case UNDECIDED = 0
}

struct PlayResult {
    var gameState: GameState?
    var gameComplete: Bool
    var winningPlayer: Player?
}

/**
    The game engine for tic-tac-toe.  Responsible for determining the game moves.
    Original explaination/pseudo-code of min-maxing taken from http://neverstopbuilding.com/minimax
*/

/**
    For this technical excercise, I've done the game engine in a stateless form (all static methods).  This
    leads to some inefficiencies, as it's constantly re-checking board state, but it helps simplify the 
    programming model.  (And given the small data structure, the overhead is probably minimal).

    Advantages of stateless form is that gamestate can be passed on to any game engine instance without care
    of what game engine handled the previous move.  This is benefical when theres a large cluster of instances 
    and reduces housekeeping.
*/
class T3GameEngine {
    
    let defaultStartGameSquarePos = GameSquarePos(row: 1, col: 1);
    
    /*
        Returns a Gameboard object with the next move populated, or nil
        if the board is in an invalid state
    */
    static func playNextMove(gameState: GameState, asPlayer player: Player) -> PlayResult {
        
        if(!canPlayerPlayNext(gameState, player: player)) {
            // crash hard, we wont deal w/ edge cases in this excercise
            println("Invalid gameState, player cannot play next.")
            exit(1)
        }
        
        if isGameFinished(gameState) {
            if let winner = getWinner(gameState) {
                return PlayResult(gameState: gameState, gameComplete: true, winningPlayer: winner.0)
            } else {
                return PlayResult(gameState: gameState, gameComplete: true, winningPlayer: nil)
            }
        }
        
        // handle case if board is unplayed
        if gameState.unplayedPositions.count == DEFAULT_GAMEBOARD_SQUARES {
            // pick a random place to start
            let randStart = Int(arc4random_uniform(UInt32(DEFAULT_GAMEBOARD_SQUARES)))
            let newGameState = setSquare(gameState, pos: GameSquarePos.getGameSquareForArrayPos(randStart), asPlayer: player)
            // first move can never win game
            return PlayResult(gameState: newGameState, gameComplete: false, winningPlayer: nil)
        } else {
            return minMaxBoard(gameState, maxForPlayer: player, currentTurnPlayer: player).0
        }
    }
    
    static func minMaxBoard(gameState: GameState, maxForPlayer: Player, currentTurnPlayer: Player) -> (PlayResult, Int) {
        
        if isGameFinished(gameState) {
            if let winner = getWinner(gameState) {
                return (PlayResult(gameState: gameState, gameComplete: true, winningPlayer: winner.0), scoreForPlayer(gameState, asPlayer: maxForPlayer))
            } else {
                return (PlayResult(gameState: gameState, gameComplete: true, winningPlayer: nil), scoreForPlayer(gameState, asPlayer: maxForPlayer))
            }
        }
        
        // arrays for scorekeeping
        var availableMoves = [GameState]()
        var possibleStates = [PlayResult, Int]()
        
        // find highest score out of all remaining moves
//        println("Processing unplayed positions, total remaining: \(gameState.unplayedPositions.count)")
        for unplayed in gameState.unplayedPositions {
            let gs = setSquare(gameState, pos: unplayed, asPlayer: currentTurnPlayer)
            availableMoves.append(gs)
            possibleStates.append(minMaxBoard(gs, maxForPlayer: maxForPlayer, currentTurnPlayer: currentTurnPlayer.getOpponent()))
        }
        
        // if current player is max player, return MAX value, else return MIN value
        // seed with initial value
        var minMaxIndex = 0
        
//        println("checking possible states:", possibleStates.count)
        // loop through rest of collection
        for i in 0 ..< possibleStates.count {
            
            if maxForPlayer == currentTurnPlayer {
                if possibleStates[minMaxIndex].1 < possibleStates[i].1 {
                    minMaxIndex = i
                }
            } else {
                if possibleStates[minMaxIndex].1 > possibleStates[i].1 {
                    minMaxIndex = i
                }
            }
        }
        
        return (PlayResult(gameState: availableMoves[minMaxIndex], gameComplete: false, winningPlayer: nil), possibleStates[minMaxIndex].1)
    }
    
    static func scoreForPlayer(gameState: GameState, asPlayer: Player) -> Int {
        
        if let winner = getWinner(gameState) {
            if winner.0 == asPlayer {
                return GameScoring.PLAYER_WIN.rawValue
            } else {
                return GameScoring.OPPONENT_WIN.rawValue
            }
        } else {
            // no winner, return zero.
            return GameScoring.UNDECIDED.rawValue
        }
    }
    
    /**
    Attempts to play a move as a given player.  Will return `GameState` if the move
    is legal and the game is not in an ended state.  Nil otherwise.
    */
    static func setSquare(gameState: GameState, pos: GameSquarePos, asPlayer player: Player) -> GameState {
        
        var newSquares = gameState.squares
        newSquares[GameSquarePos.getArrayPosForGameSquarePos(pos)] = player
        var gs = GameState()
        gs.squares = newSquares
        return gs
    }
    
    static func isValidGameState(gameState: GameState) -> Bool {
        
        let unplayed = gameState.unplayedPositions.count
        let xCount = gameState.getPlayerPositions(Player.X).count
        let oCount = gameState.getPlayerPositions(Player.O).count
        
        // if the basic math adds up, and that both players have the same amount of moves (or +1)
        if unplayed + xCount + oCount == (DEFAULT_GAMEBOARD_SQUARES) {
            if (abs(xCount - oCount) > 1) {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    static func canPlayerPlayNext(gameState: GameState, player: Player) -> Bool {
        
        var xCount = gameState.getPlayerPositions(Player.X).count
        var oCount = gameState.getPlayerPositions(Player.O).count
        
        // increment based on
        if player == Player.X {
            xCount++
        } else {
            oCount++
        }
        
        if (abs(xCount - oCount) > 1) {
            return false
        } else {
            return true
        }
    }
    
    static func isGameFinished(gameState: GameState) -> Bool {
        
        // game is finished if totalMoves == totalSquares, or
        // there is a winner
        if getWinner(gameState) != nil || (gameState.unplayedPositions.count == 0) {
            return true
        } else {
            return false
        }
    }
    
    static func getWinner(gameState: GameState) -> (Player, [GameSquarePos])? {
        
        // check for win on all legal lines
        for line in self.getAllLegalLines() {
            if let winner = self.winnerOnGivenLine(gameState, line: line) {
                return winner
            }
        }
        
        return nil
    }
    
    // private/internal functions
    static private func winnerOnGivenLine(gameState: GameState, line: [GameSquarePos]) -> (Player, [GameSquarePos])? {
        
        var lastPlayer: Player?
        for pos in line {
            
            if let p = gameState.getPlayerForPosition(pos) {
                if lastPlayer == nil {
                    lastPlayer = p
                } else {
                    if p != lastPlayer {
                        return nil
                    }
                }
            } else {
                return nil
            }
        }
        return (lastPlayer!, line)
    }
    
    static private func getAllLegalLines() -> [[GameSquarePos]] {
        
        var legalLines = self.getHorizLineArrays() + self.getVertLineArrays() + self.getDiagonalLineArrays()
        // quick sanity check (do something more severe if production app)
        if legalLines.count != LEGAL_WINNING_LINES {
            println("DID NOT FIND EXPECTED AMOUNT OF LEGAL LINES FOR BOARD")
        }
        return legalLines
    }
    
    static private func getHorizLineArrays() -> [[GameSquarePos]] {
        
        var arrays = [[GameSquarePos]]()
        
        for rowIndex in 0 ..< DEFAULT_GAMEBOARD_SIZE {
            var horizArray = [GameSquarePos]()
            for counter in 0 ..< DEFAULT_GAMEBOARD_SIZE {
                horizArray.append(GameSquarePos(row: rowIndex, col: counter))
            }
            arrays.append(horizArray)
        }
        return arrays
    }
    
    
    static private func getVertLineArrays() -> [[GameSquarePos]] {
        
        var arrays = [[GameSquarePos]]()
        
        for colIndex in 0 ..< DEFAULT_GAMEBOARD_SIZE {
            var vertArray = [GameSquarePos]()
            for counter in 0 ..< DEFAULT_GAMEBOARD_SIZE {
                vertArray.append(GameSquarePos(row: counter, col: colIndex))
            }
            arrays.append(vertArray)
        }
        return arrays
    }
    
    static private func getDiagonalLineArrays() -> [[GameSquarePos]] {
        
        var arrays = [[GameSquarePos]]()
        
        // check forward diagonal
        var forwardDiagonal = [GameSquarePos]()
        for index in 0 ..< DEFAULT_GAMEBOARD_SIZE {
            forwardDiagonal.append(GameSquarePos(row: index, col: index))
        }
        arrays.append(forwardDiagonal)
        
        // check reverse diagonal
        var reverseDiagonal = [GameSquarePos]()
        for index in 0 ..< DEFAULT_GAMEBOARD_SIZE {
            reverseDiagonal.append(GameSquarePos(row: index, col: (DEFAULT_GAMEBOARD_SIZE - 1) - index))
        }
        arrays.append(reverseDiagonal)
        
        return arrays
    }
}