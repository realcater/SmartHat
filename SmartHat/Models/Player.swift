import Foundation

class Player: Codable, Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: UUID?
    var name: String
    var tellGuessed: Int
    var listenGuessed: Int
    var accepted: Bool
    var lastTimeInGame: String
    var ttlGuesses: Int {
        get {
            return tellGuessed + listenGuessed
        }
    }
    var inGame: Bool {
        guard let date = lastTimeInGame.convertFromZ() else { return false }
        return -date.timeIntervalSinceNow < K.Server.settings.checkOffline
    }
    init(id: UUID? = nil, name: String, accepted: Bool = false) {
        self.id = id
        self.name = name
        self.tellGuessed = 0
        self.listenGuessed = 0
        self.accepted = accepted
        self.lastTimeInGame = Date(timeIntervalSince1970: 0).convertTo()
    }
}
