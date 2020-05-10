import Foundation

class GameData: Codable {
    var players: [Player] = []
    var settings: Settings
    var leftWords: [String] = []
    var guessedWords: [String] = []
    var missedWords: [String] = []
    var basketWords: [String] = []
    var basketStatus: [WordStatus] = []
    var currentWord: String = ""
    var tellerNumber: Int = -1
    var listenerNumber: Int = 0
    var dist: Int = 1
    var started = false
    var prevTellerNumber: Int = -1
    var prevListenerNumber: Int = 0
    
    init(settings: Settings, players: [Player]) {
        self.players = players
        self.settings = settings

        var allWords: [String] = []
        for wordsDifficulty in settings.difficulty.toWordDifficulty() {
            allWords.append(contentsOf: Words.words[wordsDifficulty]!)
        }
        let wordsQty = settings.wordsQty
        for _ in 0..<wordsQty {
            let number = Int.random(in: 0 ..< allWords.count)
            Helper.move(str: allWords[number], from: &allWords, to: &leftWords)
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
    
    func getRandomWordFromPool() -> Bool {
        if leftWords.count == 0 { return false }
        let number = Int.random(in: 0 ..< leftWords.count)
        currentWord = leftWords[number]
        return true
    }
    
    func setWordGuessed() {
        Helper.move(str: currentWord, from: &leftWords, to: &guessedWords)
        currentTeller.tellGuessed+=1
        currentListener.listenGuessed+=1
        basketWords.append(currentWord)
        basketStatus.append(.guessed)
    }
    
    func setWordMissed() {
        Helper.move(str: currentWord, from: &leftWords, to: &missedWords)
        basketWords.append(currentWord)
        basketStatus.append(.missed)
    }
    
    func setWordLeft() {
        basketWords.append(currentWord)
        basketStatus.append(.left)
    }
    func startNewPair() {
        prevTellerNumber = tellerNumber
        prevListenerNumber = listenerNumber
        
        if listenerNumber == 2 { started = true }
        
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
    }
    func isOneFullCircle() -> Bool {
        return tellerNumber == 0 && listenerNumber == 1 && started
    }
    func changeStatusInBasket(for num: Int) {
        let word = basketWords[num]
        switch basketStatus[num] {
        case .guessed:
            Helper.move(str: word, from: &guessedWords, to: &leftWords)
            basketStatus[num] = .left
            players[prevListenerNumber].listenGuessed-=1
            players[prevTellerNumber].tellGuessed-=1
            
        case .missed:
            Helper.move(str: word, from: &missedWords, to: &guessedWords)
            basketStatus[num] = .guessed
            players[prevListenerNumber].listenGuessed+=1
            players[prevTellerNumber].tellGuessed+=1
        case .left:
            Helper.move(str: word, from: &leftWords, to: &missedWords)
            basketStatus[num] = .missed
        }
    }
}

enum GameDifficulty: Int, Codable, CaseIterable {
    case veryEasy
    case easy
    case normal
    case hard
    case veryHard
    case separator1
    case easyMix
    case normalMix
    case hardMix
    func toWordDifficulty() -> [WordsDifficulty] {
        switch self {
        case .veryEasy: return [.veryEasy]
        case .easy: return [.easy]
        case .normal: return [.normal]
        case .hard: return [.hard]
        case .veryHard: return [.veryHard]
        case .separator1: return []
        case .easyMix: return [.veryEasy, .easy]
        case .normalMix: return [.easy,.normal,.hard]
        case .hardMix: return [.hard,.veryHard]
        }
    }
    func name() -> String {
        switch self {
        case .veryEasy: return "Детский (1)"
        case .easy: return "Легко (2)"
        case .normal: return "Норм (3)"
        case .hard: return "Сложно (4)"
        case .veryHard: return "Безумно (5)"
        case .separator1: return "-----"
        case .easyMix: return "Easy Mix (1-2)"
        case .normalMix: return "Norm Mix (2-4)"
        case .hardMix: return "Hard Mix (4-5)"
        }
    }
}

enum WordsDifficulty {
    case veryEasy
    case easy
    case normal
    case hard
    case veryHard
}

enum WordStatus: Int, Codable {
    case guessed
    case left
    case missed
}

struct Settings: Codable {
    var difficultyRow: Int
    var wordsQtyRow: Int
    var roundDurationRow: Int
    
    var difficulty: GameDifficulty {
        return K.SettingsRow.difficulty[difficultyRow]
    }
    var wordsQty: Int {
        return K.SettingsRow.wordsQty[wordsQtyRow]
    }
    var roundDuration: Int {
        return K.SettingsRow.roundDuration[roundDurationRow]
    }
}
