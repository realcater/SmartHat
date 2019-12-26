import Foundation

enum Difficulty {
    case easy
    case normal
    case hard
}

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
    var leftWords: [String] = []
    var guessedWords: [String] = []
    var missedWords: [String] = []
    
    var time: Int
    
    var tellerNumber: Int = -1
    var listenerNumber: Int = 0
    var dist: Int = 1
    
    init(wordsQty: Int, difficulty: Difficulty, time: Int, playersNames: NSMutableArray) {
        self.time = time
        for name in playersNames {
            self.players.append(Player(name: name as! String))
        }

        var allWords = Words.words[difficulty]!
        for _ in 0..<wordsQty {
            let number = Int.random(in: 0 ..< allWords.count)
            Helper.move(
                str: allWords[number],
                from: &allWords,
                to: &leftWords)
        }
    }
    var currentTeller: Player {
        get {
            return players[tellerNumber]
        }
    }
    var currentListener: Player {
        get {
            return players[listenerNumber]
        }
    }
    
    func getRandomWordFromPool() -> String {
        let number = Int.random(in: 0 ..< leftWords.count)
        return leftWords[number]
    }
    
    func setGuessed(_ word: String) {
        Helper.move(str: word, from: &leftWords, to: &guessedWords)
    }
    
    func startNewPair() {
        tellerNumber+=1
        listenerNumber+=1
        if listenerNumber == players.count {
            listenerNumber = 0
        }
        if tellerNumber == players.count {
            dist+=1
            if dist == players.count {
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
