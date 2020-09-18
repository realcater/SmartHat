import Foundation

class Game: Codable {
    var id: UUID
    var code: String?
    var data: GameData
    var userOwnerID: UUID
    var turn: Int
    var guessedThisTurn: Int
    var lastWord: Word?
    var explainTime: String
    var basketChange: Int

    internal init(id: UUID, data: GameData, userOwner: UUID, code: String?) {
        self.id = id
        self.data = data
        self.userOwnerID = userOwner
        self.code = code
        self.turn = -1
        self.guessedThisTurn = 0
        self.basketChange = 0
        self.explainTime = Date().addingTimeInterval(-100000).convertTo()
    }
    
    class ListElement: Codable {
        var id: String
        var userOwnerName: String
        var turn: Int
        var createdAt: String
        
        init(gameID: String, userOwnerName: String, turn: Int, createdAt: String) {
            self.id = gameID
            self.userOwnerName = userOwnerName
            self.turn = turn
            self.createdAt = createdAt
        }
    }
    class Created: Codable {
        var id: UUID
        var code: String?
    }
    
    class Frequent: Codable {
        var turn: Int
        var guessedThisTurn: Int
        var lastWord: Word?
        var explainTime: String
        var basketChange: Int
        
        internal init(turn: Int, guessedThisTurn: Int, lastWord: Word?, explainTime: String, basketChange: Int) {
            self.turn = turn
            self.guessedThisTurn = guessedThisTurn
            self.lastWord = lastWord
            self.explainTime = explainTime
            self.basketChange = basketChange
        }
        
        var timeFromExplain: Int? {
            //guard let time = explainTime?.timeIntervalSinceNow else { return nil }
            let time = -Int(explainTime.convertFromZ()!.timeIntervalSinceNow)
            return ((time < 0) || (time > 60)) ? nil : time
        }
    }
    func convertToFrequent() -> Frequent {
        return Frequent(turn: turn, guessedThisTurn: guessedThisTurn,  lastWord: lastWord, explainTime: explainTime, basketChange: basketChange)
    }
    
    func copyValues(of game: Game) {
        self.code = game.code
        self.data = game.data
        self.turn = game.turn
        self.guessedThisTurn = game.guessedThisTurn
        self.basketChange = game.basketChange
        self.explainTime = game.explainTime
        self.lastWord = game.lastWord
    }
}
