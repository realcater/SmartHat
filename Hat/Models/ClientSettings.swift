import Foundation

//settings kept in server
class ClientSettings: Codable {
    internal init(id: UUID? = nil, updatePlayersStatus: Double, updateGameList: Double, checkOffline: Double, updateFrequent: Double, updateFullTillNextTry: Double) {
        self.id = id
        self.updatePlayersStatus = updatePlayersStatus
        self.updateGameList = updateGameList
        self.checkOffline = checkOffline
        self.updateFrequent = updateFrequent
        self.updateFullTillNextTry = updateFullTillNextTry
    }
    var id: UUID?
    var updatePlayersStatus: Double
    var updateGameList: Double
    var checkOffline: Double
    var updateFrequent: Double
    var updateFullTillNextTry: Double
}
