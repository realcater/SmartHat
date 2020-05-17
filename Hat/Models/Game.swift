import Foundation

class Game: Codable {
    var id: UUID
    var data: GameData
    var userOwnerID: UUID
    var turn: Int
    var guessedThisTurn: Int
    var explainTime: String
    var basketChange: Int

    internal init(id: UUID, data: GameData, userOwner: UUID) {
        self.id = id
        self.data = data
        self.userOwnerID = userOwner
        self.turn = 0
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
    class UUIDOnly: Codable {
        var gameID: UUID
    }
    
    class Frequent: Codable {
        var turn: Int
        var guessedThisTurn: Int
        var explainTime: String
        var basketChange: Int
        
        internal init(turn: Int, guessedThisTurn: Int, explainTime: String, basketChange: Int) {
            self.turn = turn
            self.guessedThisTurn = guessedThisTurn
            self.explainTime = explainTime
            self.basketChange = 0
        }
        
        var timeFromExplain: Int? {
            //guard let time = explainTime?.timeIntervalSinceNow else { return nil }
            let time = -Int(explainTime.convertFromZ()!.timeIntervalSinceNow)
            return ((time < 0) || (time > 60)) ? nil : time
        }
    }
    func convertToFrequent() -> Frequent {
        return Frequent(turn: turn, guessedThisTurn: guessedThisTurn, explainTime: explainTime, basketChange: basketChange)
    }
}
