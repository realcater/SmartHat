import UIKit

struct K {
    static let secsAfter = 3
    static let startPlayersNames: NSMutableArray = [
        "Дима",
        "Лена",
        "Глеб",
        "Аня"
        ]
    static let diffNames : [Difficulty: String] = [
        .easy: "Изи",
        .normal: "Норм",
        .hard: "Хард"
    ]
    
    static let statusWordImages: [WordStatus: String] = [
        .guessed: "✅",
        .missed: "❌",
        .left: "🎩"
    ]
    
    static let useSmallerFonts = (UIScreen.main.currentMode!.size.width >= 750) ? false : true
    static let cornerRadius : CGFloat = 16
    
    struct Sounds {
        static let click = initSound(filename: "click.wav", volume: 0.2)
        static let correct = initSound(filename: "true.wav", volume: 0.2)
        static let error = initSound(filename: "false.wav", volume: 0.5)
        static let applause = initSound(filename: "applause.wav")
        static let countdown = initSound(filename: "countdown.mp3")
        static let timeOver = initSound(filename: "timeOver2.mp3")
    }
    
    struct Colors {
        static let foreground = UIColor(red: 0, green: 110/256, blue: 182/256, alpha: 1)
        static let foregroundLighter = UIColor(red: 0, green: 165/256, blue: 1, alpha: 1)
        static let foregroundDarker = UIColor(red: 0, green: 73/256, blue: 121/256, alpha: 1)
        static let background = UIColor.white
        static let redDarker = UIColor(red: 148/256, green: 17/256, blue: 0, alpha: 1)
        static let gray = UIColor.gray
        static let lightGray = UIColor(red: 170/256, green: 170/256, blue: 170/256, alpha: 1)
        
        static let resultBar = [true: UIColor(red: 0, green: 143/256, blue: 0, alpha: 1),
                                false: UIColor(red: 200/256, green: 0, blue: 0, alpha: 1)]
        struct Buttons {
            static let active = UIColor(red: 0, green: 110/256, blue: 182/256, alpha: 1)
            static let disabled = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        }
    }
    
    struct Labels {
        struct Buttons {
            }
        struct Titles {
        }
    }
    
    struct Alpha {
        struct Background {
            static let main : CGFloat = 0.07
        }
    }
    struct FileNames {
        static let background = "textBackground"
    }
    struct Delays {
        static let moveOneRow = 0.2
        static let notGuessedBtn = 1.3
        static let goBtn = 2.2
    }
    static let timeWithClicks = 3
}
