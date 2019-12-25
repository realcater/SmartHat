class Player {
    var name: String
    var sayGuessed: Int
    var listenGuessed: Int
    var ttlGuesses: Int {
        get {
            return sayGuessed + listenGuessed
        }
    }
    
    init(name: String) {
        self.name = name
        sayGuessed = 0
        listenGuessed = 0
    }
}

class Game {
    var players: [Player] = []
    var words: [String] = []
    var tellerNumber: Int = -1
    var listenerNumber: Int = 0
    var dist: Int = 1
    
    var playersQty: Int {
        get {
            return players.count
        }
    }
    func initWords() {
        words = K.words
    }
    
    func startRound() {
        tellerNumber+=1
        listenerNumber+=1
        if listenerNumber == playersQty {
            listenerNumber = 0
        }
        if tellerNumber == playersQty {
            dist+=1
            if dist==playersQty {
                tellerNumber = 0
                listenerNumber = 1
                dist = 1
            } else {
                tellerNumber = 0
                listenerNumber = tellerNumber + dist
            }
        }
        print(tellerNumber, listenerNumber)
    }
}
