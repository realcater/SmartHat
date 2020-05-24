// Contains just an array of Players (to make it refferral)
// Also load/save methods for offline game added

import Foundation

class PlayersList {
    var players: [Player] = []
    let fileName = "offline"
    
    func loadFromFile() {
        players = Helper.load(from: fileName) ?? K.startPlayers
    }
    func saveToFile() {
        Helper.save(players,to: fileName)
    }
}
