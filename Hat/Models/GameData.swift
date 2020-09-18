import Foundation

struct GameData: Codable {
    var players: [Player] = []
    var settings: Settings
    var leftWords: [Word] = []
    var guessedWords: [Word] = []
    var missedWords: [Word] = []
    var basketWords: [Word] = []
    var basketStatus: [GuessedStatus] = []
    var currentWord: Word = Word(text: "", description: "")
    var wordsData: [WordData] = []
    
    init(settings: Settings, players: [Player]) {
        self.players = players
        self.settings = settings
        
        var allWords: [Word] = []
        for wordsDifficulty in settings.difficulty.toWordDifficulty() {
            allWords.append(contentsOf: Words.words[wordsDifficulty]!)
        }
        let wordsQty = settings.wordsQty
        for _ in 0..<wordsQty {
            let number = Int.random(in: 0 ..< allWords.count)
            (allWords,leftWords) = Helper.move2(word: allWords[number], from: allWords, to: leftWords)
        }
    }
}


enum GameDifficulty: Int, Codable, CaseIterable {
    case mathEasy
    func toWordDifficulty() -> [WordsDifficulty] {
        switch self {
        case .mathEasy: return [.mathEasy]
        }
    }
    func name() -> String {
        switch self {
        case .mathEasy: return "Математика"
        }
    }
}

enum WordsDifficulty {
    case mathEasy
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
    var word: Word
    var timeGuessed: Int
    var guessedStatus: GuessedStatus
}
