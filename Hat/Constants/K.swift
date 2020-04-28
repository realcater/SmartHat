import UIKit

struct K {
    
    static let startPlayersNames: NSMutableArray = [
        "Анжела",
        "Евстигней",
        "Снежана",
        "Евлампий"
        ]
    static let startPlayers: [Player] = [
        Player(name: "Анжела"),
        Player(name: "Евстигней"),
        Player(name: "Снежана"),
        Player(name: "Евлампий")
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
    
    static let windowsCornerRadius : CGFloat = 16
    static let circleLeftTimeCornerRadius : CGFloat = 40
    
    
    struct Sounds {
        static let click = initSound(filename: "click.wav", volume: 0.2)
        static let correct = initSound(filename: "true.wav", volume: 0.2)
        static let error = initSound(filename: "false.wav", volume: 0.1)
        static let applause = initSound(filename: "applause.wav", volume: 0.2)
        static let countdown = initSound(filename: "countdown.mp3")
        static let timeOver = initSound(filename: "timeOver.mp3")
    }
    
    struct Colors {
        static let foreground = UIColor(red: 0, green: 110/256, blue: 182/256, alpha: 1)
        static let foregroundLighter = UIColor(red: 0, green: 165/256, blue: 1, alpha: 1)
        static let foregroundDarker = UIColor(red: 0, green: 73/256, blue: 121/256, alpha: 1)
        static let redDarker = UIColor(red: 148/256, green: 17/256, blue: 0, alpha: 1)
        static let gray = UIColor.gray
        static let lightGray = UIColor(red: 170/256, green: 170/256, blue: 170/256, alpha: 1)
        static let background = UIColor.white
    }

    struct Alpha {
        struct Background {
            static let main : CGFloat = 0.07
        }
    }
    struct FileNames {
        static let background = "textBackground"
        static let addPlayerIcon = "addPlayerIcon"
        static let waitIcon = "waitIcon"
    }
    struct Delays {
        static let moveOneRow = 0.2
        static let notGuessedBtn = 1.3
        static let goBtn = 2.2
        static let withClicks = 5
        static let pageChangeViaPageControl = 0.3
    }
    struct Urls {
        static let fbDmitry = "https://www.facebook.com/dmitry.realcater"
        static let fbApp = "https://www.facebook.com/hat.allvsall"
    }
    struct Margins {
        static let helpScreen: CGFloat = 0
    }
}
