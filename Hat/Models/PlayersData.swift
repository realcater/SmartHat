// Contains just an array of Players (to make it refferral)
// Also load/save methods for offline game added

import Foundation

class PlayersData {
    var players: [Player] = []
    var plistFileName : String {
        let fileName = "offline"
        return Helper.plistFileName(fileName)
    }
    
    func load() {
        if let encodedData = NSKeyedUnarchiver.unarchiveObject(withFile: plistFileName) as? Data, let players = try? JSONDecoder().decode([Player].self, from: encodedData) {
            self.players = players
        } else {
            self.players = K.startPlayers
        }
    }
    func save() {
        let encodedData = try! JSONEncoder().encode(players)
        NSKeyedArchiver.archiveRootObject(encodedData, toFile: plistFileName)
    }
}
