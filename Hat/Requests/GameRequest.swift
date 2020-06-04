import Foundation

struct GameRequest {
    static func create(_ gameData: GameData, completion: @escaping (Result<Game.Created>) -> Void) {
        sendRequestInOut(
                    stringUrl: "games",
                    httpMethod: "POST",
                    dataIn: gameData,
                    completion: completion)
    }
    static func search(by gameID: UUID, completion: @escaping (Result<Game>) -> Void) {
        sendRequestOut(
                    stringUrl: "games/"+gameID.uuidString,
                    httpMethod: "GET",
                    completion: completion)
    }
    static func searchMine(completion: @escaping (Result<[Game.ListElement]>) -> Void) {
        print("\n\n\(Date()):========== searchMine (START)===========")
        sendRequestOut(
                    stringUrl: "games/mine",
                    httpMethod: "GET",
                    completion: completion)
    }
    static func join(joinData: JoinData, completion: @escaping (Result<Game>) -> Void) {
        sendRequestInOut(
                    stringUrl: "games/join",
                    httpMethod: "POST",
                    dataIn: joinData,
                    completion: completion)
    }
    static func add(to gameID: UUID, player: Player, completion: @escaping (OkResult) -> Void) {
        sendRequestIn(
                    stringUrl: "games/"+gameID.uuidString+"/addPlayer",
                    httpMethod: "POST",
                    dataIn: player,
                    completion: completion)
    }
    static func accept(by gameID: UUID, completion: @escaping (Result<Game>) -> Void) {
        sendRequestOut(
                    stringUrl: "games/"+gameID.uuidString+"/accept",
                    httpMethod: "POST",
                    completion: completion)
    }
    static func reject(gameID: UUID, completion: @escaping (OkResult) -> Void) {
        sendRequest(
                    stringUrl: "games"+gameID.uuidString+"/reject",
                    httpMethod: "POST",
                    completion: completion)
    }
    static func get(gameID: UUID, completion: @escaping (Result<Game>) -> Void) {
        sendRequestOut(
                    stringUrl: "games/"+gameID.uuidString,
                    httpMethod: "GET",
                    completion: completion)
    }
    static func getFrequent(gameID: UUID, completion: @escaping (Result<Game.Frequent>) -> Void) {
        sendRequestOut(
                    stringUrl: "games/"+gameID.uuidString+"/frequent",
                    httpMethod: "GET",
                    completion: completion)
    }
    static func update(game: Game, completion: @escaping (OkResult) -> Void) {
        sendRequestIn(
                    stringUrl: "games/" + game.id.uuidString + "/update",
                    httpMethod: "POST",
                    dataIn: game,
                    completion: completion)
    }
    
    static func updateFrequent(for gameID: UUID, frequentData: Game.Frequent, completion: @escaping (OkResult) -> Void) {
        sendRequestIn(
                    stringUrl: "games/"+gameID.uuidString+"/updatefrequent",
                    httpMethod: "POST",
                    dataIn: frequentData,
                    completion: completion)
    }
    static func getPlayersStatus(gameID: UUID, completion: @escaping (Result<StatusBeforeStart>) -> Void) {
        sendRequestOut(
                    stringUrl: "games/"+gameID.uuidString+"/players",
                    httpMethod: "GET",
                    completion: completion)
    }
    static func delete(gameID: UUID, completion: @escaping (OkResult) -> Void) {
            sendRequest(
                        stringUrl: "games/"+gameID.uuidString,
                        httpMethod: "DELETE",
                        completion: completion)
    }
}

struct PlayerStatus: Codable {
    var playerID: UUID
    var playerName: String
    var accepted: Bool
    var lastTimeInGame: String
    
    var inGame: Bool {
        guard let date = lastTimeInGame.convertFromZ() else { return false }
        return -date.timeIntervalSinceNow < K.Server.settings.checkOffline
    }
}

struct StatusBeforeStart: Codable {
    var players: [Player]
    var turn: Int
}

struct JoinData: Codable {
    var code: String
    var additionalName: String?
    
    init(code: String) {
        if code.contains(",,,") {
            self.code = String(code.prefix(4))
            additionalName = String(code.suffix(code.count-7))
        } else {
            self.code = code
            additionalName = nil
        }
    }
}

