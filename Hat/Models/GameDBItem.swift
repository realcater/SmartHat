import Foundation

class GameDBItem {
    var id: UUID
    var game: Game
    var userOwner: User
    
    internal init(id: UUID, game: Game, userOwner: User) {
        self.id = id
        self.game = game
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
