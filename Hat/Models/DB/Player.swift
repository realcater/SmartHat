import Foundation

class Player: Codable, Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: UUID?
    var name: String
    var tellGuessed: Int
    var listenGuessed: Int
    var ttlGuesses: Int {
        get {
            return tellGuessed + listenGuessed
        }
    }
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
        tellGuessed = 0
        listenGuessed = 0
    }
}
