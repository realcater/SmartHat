import UIKit

struct K {
    struct Server {
        //static let name = "http://192.168.1.190:8080/api/"
        static let name = "https://thehat-online.herokuapp.com/api/"
        
        static let currentAppVersion = 2
        
        static let warnings: [RequestError: String] = [
            .noConnection: "Нет связи или сервер не отвечает",
            .unauthorised: "Пользователь не авторизован",
            .notFound: "Не найдено",
            .duplicate: "Этот никнейм уже занят",
            .JSONParseError: "Ошибка данных",
            .gameEnded: "Игра завершена",
            .other: "Ошибка сервера"
        ]
        static let reservedPlayerNames = [
            "admin",
            "app"
        ]
        static var settings = ClientSettings(
            updatePlayersStatus: 5.0,
            updateGameList: 5.0,
            checkOffline: 10.0,
            updateFrequent: 1.0,
            updateFullTillNextTry: 1.0,
            minimumAppVersion: currentAppVersion)
     }
    static var sounds = Sounds()
    static var appSettings = AppSettings(soundDelegate: sounds)
    
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
    
    static let statusWordImages: [GuessedStatus: String] = [
        .guessed: "✅",
        .missed: "❌",
        .left: "🎩"
    ]
    
    static let windowsCornerRadius : CGFloat = 16
    
    struct CircleCornerRadius {
        static let big: CGFloat = 40
        static let small: CGFloat = 40
    }
    
    struct Colors {
        static let foreground = UIColor(red: 0, green: 110/256, blue: 182/256, alpha: 1)
        static let foreground80 = UIColor(red: 0, green: 110/256, blue: 182/256, alpha: 0.8)
        static let foreground40 = UIColor(red: 0, green: 110/256, blue: 182/256, alpha: 0.4)
        static let foregroundLighter = UIColor(red: 0, green: 165/256, blue: 1, alpha: 1)
        static let foregroundDarker = UIColor(red: 0, green: 73/256, blue: 121/256, alpha: 1)
        static let redDarker = UIColor(red: 148/256, green: 17/256, blue: 0, alpha: 1)
        static let red = UIColor(red: 0.8, green: 0.2, blue: 0, alpha: 1)
        static let red80 = UIColor(red: 0.8, green: 0.1, blue: 0, alpha: 0.8)
        static let red40 = UIColor(red: 0.8, green: 0.1, blue: 0, alpha: 0.4)
        static let green = UIColor(red: 0.2, green: 0.7, blue: 0, alpha: 1)
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
        static let offlineIcon = "offline"
        static let onlineIcon = "online"
    }
    struct Delays {
        static let moveOneRow = 0.2
        static let notGuessedBtn = 1.0
        static let goBtn = 2.3
        static let withClicks = 5
        static let pageChangeViaPageControl = 0.3
    }
    struct Urls {
        static let fbDmitry = "https://www.facebook.com/dmitry.realcater"
        static let fbApp = "https://www.facebook.com/hat.allvsall"
        static let vkEvgeny = "https://vk.com/eugene36"
    }
    struct Margins {
        static let helpScreen: CGFloat = 0
    }
    
    struct Name {
        static let minLength = 3
        static let maxLength = 12
        static let minLengthWarning = "Имя должно быть не менее "+String(minLength)+" символов"
        static let maxLengthWarning = "Имя должно быть не более "+String(maxLength)+" символов"
    }
    static let endTurnNumber = -1
}
