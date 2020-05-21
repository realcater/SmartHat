import Foundation

struct GameData: Codable {
    var players: [Player] = []
    var settings: Settings
    var leftWords: [String] = []
    var guessedWords: [String] = []
    var missedWords: [String] = []
    var basketWords: [String] = []
    var basketStatus: [GuessedStatus] = []
    var currentWord: String = ""
    var wordsData: [WordData] = []
    
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
            (allWords,leftWords) = Helper.move2(str: allWords[number], from: allWords, to: leftWords)
            //Helper.move(str: allWords[number], from: &allWords, to: &leftWords)
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
