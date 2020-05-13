import Foundation

class GameData: Codable {
    var players: [Player] = []
    var settings: Settings
    var leftWords: [String] = []
    var guessedWords: [String] = []
    var missedWords: [String] = []
    var basketWords: [String] = []
    var basketStatus: [GuessedStatus] = []
    var currentWord: String = ""
    var turn: Int = 0
    var explainTime: String
    var wordsData: [WordData] = []
    var guessedThisTurn: Int = 0
    
    init(settings: Settings, players: [Player]) {
        self.players = players
        self.settings = settings
        self.explainTime = Date().addingTimeInterval(84600).convertTo(use: "yyyy-MM-dd'T'HH:mm:ss'Z'")

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
    
    var everyPlayerReady: Bool {
        return !players.map{ $0.accepted && $0.inGame }.contains(false)
    }
    
    var tellerNumber: Int {
        return turn % players.count
    }
    var listenerNumber: Int {
        let bigRoundLength = players.count * (players.count-1)
        let turnInBigRound = turn % bigRoundLength
        let round = turnInBigRound / players.count
        return (tellerNumber+round+1) % players.count
    }
    var prevTellerNumber: Int {
        return (turn-1) % players.count
    }
    var prevListenerNumber: Int {
        let bigRoundLength = players.count * (players.count-1)
        let turnInBigRound = (turn-1) % bigRoundLength
        let round = turnInBigRound / players.count
        return (prevTellerNumber+round+1) % players.count
    }
    var currentTeller: Player {
        return players[tellerNumber]
    }
    var currentListener: Player {
        return players[listenerNumber]
    }
    var isOneFullCircle: Bool {
        return (turn > 0) && (turn % ((players.count)*(players.count-1)) == 0)
    }
    var timeFromExplain: Int? {
        //guard let time = explainTime?.timeIntervalSinceNow else { return nil }
        let time = -Int(explainTime.convertFromZ()!.timeIntervalSinceNow)
        return ((time < 0) || (time > settings.roundDuration)) ? nil : time
    }
    
    func clear() {
        basketWords = []
        basketStatus = []
        wordsData = []
        guessedThisTurn = 0
    }
    
    func getRandomWordFromPool() -> Bool {
        if leftWords.count == 0 { return false }
        let number = Int.random(in: 0 ..< leftWords.count)
        currentWord = leftWords[number]
        return true
    }
    
    func setWordGuessed(time: Int) {
        wordsData.append(WordData(word: currentWord, timeGuessed: time, guessedStatus: .guessed))
        Helper.move(str: currentWord, from: &leftWords, to: &guessedWords)
        currentTeller.tellGuessed+=1
        currentListener.listenGuessed+=1
        basketWords.append(currentWord)
        basketStatus.append(.guessed)
        guessedThisTurn += 1
    }
    
    func setWordMissed(time: Int) {
        wordsData.append(WordData(word: currentWord, timeGuessed: time, guessedStatus: .missed))
        Helper.move(str: currentWord, from: &leftWords, to: &missedWords)
        basketWords.append(currentWord)
        basketStatus.append(.missed)
    }
    
    func setWordLeft(time: Int) {
        wordsData.append(WordData(word: currentWord, timeGuessed: time, guessedStatus: .left))
        basketWords.append(currentWord)
        basketStatus.append(.left)
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

enum GuessedStatus: Int, Codable {
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

struct WordData: Codable {
    var word: String
    var timeGuessed: Int
    var guessedStatus: GuessedStatus
}
