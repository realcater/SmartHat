import Foundation

class Game {
    var id: UUID
    var gameData: GameData
    var userOwner: User
    
    internal init(id: UUID, gameData: GameData, userOwner: User) {
        self.id = id
        self.gameData = gameData
        self.userOwner = userOwner
    }

    class Public: Codable {
        var gameID: String
        var userOwnerName: String
        var createdAt: String
        
        init(gameID: String, userOwnerName: String, createdAt: String) {
            self.gameID = gameID
            self.userOwnerName = userOwnerName
            self.createdAt = createdAt
        }
    }
}
