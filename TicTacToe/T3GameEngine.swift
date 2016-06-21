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
    For this technical excercise, I've done the game engine function in a stateless form.  The class is instanced
    so that the winning lines can be predetermined at class initalization, and re-used for all checks.  

    This leads to some inefficiencies, as it's constantly re-checking board state, but it helps simplify the
    programming model.  (And given the small data structure, the overhead is probably minimal).

    Advantages of stateless form is that gamestate can be passed on to any game engine instance without care
    of what game engine handled the previous move.  This is benefical when theres a large cluster of instances 
    and reduces housekeeping.
*/
class T3GameEngine {
    
    var winningLines = [[GameSquarePos]]()
    
    init () {
        initAllWinningLines()
    }
    
    /*
        Returns a Gameboard object with the next move populated, or nil
        if the board is in an invalid state
    */
    func playNextMove(gameState: GameState, asPlayer player: Player) -> PlayResult {
        
        if(getPlayerToPlayNext(gameState) != player) {
            // crash hard, we wont deal w/ edge cases in this excercise
            print("Invalid gameState, player cannot play next.")
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
        if gameState.totalMoves == 0 {
            // pick a random place to start
            let randStart = Int(arc4random_uniform(UInt32(DEFAULT_GAMEBOARD_SQUARES)))
            let newGameState = setSquare(gameState, pos: GameSquarePos.getGameSquareForArrayPos(randStart), asPlayer: player)
            // first move can never win game
            return PlayResult(gameState: newGameState, gameComplete: false, winningPlayer: nil)
        } else if gameState.totalMoves == 1 {
            // further optimize the second turn by selecting either center or one of the four corners, 
            // depending on the first player's move.  this will reduce the amount of minimaxing we have to do
            
            // check if first player grabbed center
            if gameState.getPlayerForPosition(GameSquarePos(row: 1, col: 1)) != nil {
                // take a corner 
                let newGameState = setSquare(gameState, pos: GameSquarePos(row: 2, col: 2), asPlayer: player)
                return PlayResult(gameState: newGameState, gameComplete: false, winningPlayer: nil)
            } else {
                // grab center
                let newGameState = setSquare(gameState, pos: GameSquarePos(row: 1, col: 1), asPlayer: player)
                return PlayResult(gameState: newGameState, gameComplete: false, winningPlayer: nil)
            }
        } else {
            return miniMaxBoard(gameState, maxForPlayer: player, currentTurnPlayer: player).0
        }
    }
    
    func miniMaxBoard(gameState: GameState, maxForPlayer: Player, currentTurnPlayer: Player) -> (PlayResult, Int) {
        
        if isGameFinished(gameState) {
            if let winner = getWinner(gameState) {
                return (PlayResult(gameState: gameState, gameComplete: true, winningPlayer: winner.0), scoreForPlayer(gameState, asPlayer: maxForPlayer))
            } else {
                return (PlayResult(gameState: gameState, gameComplete: true, winningPlayer: nil), scoreForPlayer(gameState, asPlayer: maxForPlayer))
            }
        }
        
        // arrays for scorekeeping
        var availableMoves = [GameState]()
        var possibleStates = [(PlayResult, Int)]()
        
        // find highest score out of all remaining moves
        for unplayed in gameState.unplayedPositions {
            let gs = setSquare(gameState, pos: unplayed, asPlayer: currentTurnPlayer)
            availableMoves.append(gs)
            possibleStates.append(miniMaxBoard(gs, maxForPlayer: maxForPlayer, currentTurnPlayer: currentTurnPlayer.getOpponent()))
        }
        
        // if current player is max player, return MAX value, else return MIN value
        // seed with initial value
        var minMaxIndex = 0
        
        // loop through rest of collection
        for i in 0 ..< possibleStates.count {
            
            // if we strictly compare on value (10 or -10, a scenario becomes possible where this
            // algorithm will uninutitively pick a move that will *still* result in a win a few moves later on over
            // a move that will result in an immediate win, so we will be greedy and grab result for states that are
            // determined to be won over just possible future wins.
            if maxForPlayer == currentTurnPlayer {
                
                if possibleStates[i].0.winningPlayer == maxForPlayer {
                    minMaxIndex = i
                    break
                } else {
                    if possibleStates[minMaxIndex].1 < possibleStates[i].1 {
                        minMaxIndex = i
                    }
                }
            } else {
                if possibleStates[minMaxIndex].1 > possibleStates[i].1 {
                    minMaxIndex = i
                }
            }
        }
        
        let selectedGameState = availableMoves[minMaxIndex]
        let playResult = PlayResult(gameState: selectedGameState, gameComplete: isGameFinished(selectedGameState), winningPlayer: getWinner(selectedGameState)?.0)
        return (playResult, possibleStates[minMaxIndex].1)
    }
    
    func scoreForPlayer(gameState: GameState, asPlayer: Player) -> Int {
        
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
    Sets square for gameState.  This does no rule checking.  Can overwrite player position, etc.
    */
    func setSquare(gameState: GameState, pos: GameSquarePos, asPlayer player: Player) -> GameState {
        
        var newSquares = gameState.squares
        let arrayPos = GameSquarePos.getArrayPosForGameSquarePos(pos)
        newSquares[arrayPos] = player
        let gs = GameState(squares: newSquares)
        return gs
    }
    
    func isValidGameState(gameState: GameState) -> Bool {
        
        let unplayed = gameState.unplayedPositions.count
        let xCount = gameState.xPositions.count
        let oCount = gameState.oPositions.count
        
        // if the basic math adds up, and that both players have the same amount of moves (or +1)
        if unplayed + xCount + oCount == (DEFAULT_GAMEBOARD_SQUARES) {
            let diff = xCount - oCount
            if diff < 0 || diff > 1 {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    
    func getPlayerToPlayNext(gameState: GameState) -> Player? {
        
        if !isValidGameState(gameState) {
            return nil
        }
        
        let diff = gameState.xPositions.count - gameState.oPositions.count
        
        if diff == 0 {
            return Player.X
        } else {
            return Player.O
        }
    }
    
    func isGameFinished(gameState: GameState) -> Bool {
        
        // game is finished if totalMoves == totalSquares, or
        // there is a winner
        if getWinner(gameState) != nil || (gameState.unplayedPositions.count == 0) {
            return true
        } else {
            return false
        }
    }
    
    func getWinner(gameState: GameState) -> (Player, [GameSquarePos])? {
        
        // check for win on all legal lines
        for line in winningLines {
            if let winner = self.winnerOnGivenLine(gameState, line: line) {
                return winner
            }
        }
        
        return nil
    }
    
    // private/internal functions
    private func winnerOnGivenLine(gameState: GameState, line: [GameSquarePos]) -> (Player, [GameSquarePos])? {
        
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
    
    private func initAllWinningLines() {
        winningLines = getHorizLineArrays() + getVertLineArrays() + getDiagonalLineArrays()
    }
    
    private func getHorizLineArrays() -> [[GameSquarePos]] {
        
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
    
    
    private func getVertLineArrays() -> [[GameSquarePos]] {
        
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
    
    private func getDiagonalLineArrays() -> [[GameSquarePos]] {
        
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