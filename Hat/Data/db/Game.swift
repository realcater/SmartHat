import Foundation

class Game {
    internal init(id: UUID, gameData: GameData, userOwner: User) {
        self.id = id
        self.gameData = gameData
        self.userOwner = userOwner
    }
    
    var id: UUID
    var gameData: GameData
    var userOwner: User
}
