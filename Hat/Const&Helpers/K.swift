import UIKit

struct K {
    struct Server {
        static let name = "http://192.168.1.190:8080/api/"
        static let duplicateNameRespondPrefix = "server: duplicate key value violates unique constraint"
        static let duplicateNameRespondPrefixLength = duplicateNameRespondPrefix.count
        static let warnings: [RequestError: String] = [
            .noConnection: "Нет связи или сервер не отвечает",
            .unauthorised: "Пользователь не авторизован",
            .notFound: "Не найдено",
            .duplicate: "Этот Никнейм уже занят",
            .other: "Ошибка сервера"
        ]
        static let reservedPlayerNames = [
            "admin",
            "app"
        ]
        struct Time {
            static let updatePlayersStatus = 5.0
        }
     }
    static let startPlayers: [Player] = [
        Player(name: "Анжела"),
        Player(name: "Евстигней"),
        Player(name: "Снежана"),
        Player(name: "Евлампий")
    ]

    struct SettingsRow {
        static let wordsQty = [20,30,40,50,60,70,80,90,100,120,140,160,250,400,600]
        static let difficulty = GameDifficulty.allCases
        static let roundDuration = [10,20,30,40,50,60]
        static let start = Settings(difficultyRow: 2, wordsQtyRow: 4, roundDurationRow: 2)
    }
    
    struct Buttons {
        static let newGameVCTitle: [Mode: String] = [
            .offline: "Играть",
            .onlineWait: "Играть",
            .onlineCreate: "Создать игру",
            .onlineReady: "Играть"
        ]
    }
    
    struct Titles {
        static let newGame: [Mode: String] = [
            .offline: "Кто играет?",
            .onlineCreate: "Кто играет?",
            .onlineWait: "Ждём игроков...",
            .onlineReady: "Все готовы!"
        ]
    }
    
    static let minPlayersQty = 2
    
    static let statusWordImages: [WordStatus: String] = [
        .guessed: "✅",
        .missed: "❌",
        .left: "🎩"
    ]
    
    static let windowsCornerRadius : CGFloat = 16
    static let circleLeftTimeCornerRadius : CGFloat = 40
    
    
    struct Sounds {
        static let click = initSound(filename: "click.wav", volume: 0.1)
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
        static let red = UIColor(red: 210/256, green: 38/256, blue: 0, alpha: 1)
        static let green = UIColor(red: 0, green: 110/256, blue: 0, alpha: 1)
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
        static let acceptedIcon = "acceptedIcon"
    }
    struct Delays {
        static let moveOneRow = 0.2
        static let notGuessedBtn = 1.1
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
    
    struct Name {
        static let minLength = 4
        static let maxLength = 12
        static let minLengthWarning = "Имя должно быть не менее "+String(minLength)+" символов"
        static let maxLengthWarning = "Имя должно быть не более "+String(maxLength)+" символов"
    }
}
