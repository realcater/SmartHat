import Foundation

enum GamesPublicResult {
    case success([Game.Public])
    case failure(RequestError)
}

enum GameDataResult {
    case success(GameData)
    case failure(RequestError)
}

enum GameIDResult {
    case success(UUID)
    case failure(RequestError)
}

enum PlayerStatusResult {
    case success([PlayerStatus])
    case failure(RequestError)
}

enum OkResult {
    case success
    case failure(RequestError)
}

enum FrequentGameDataResult {
    case success(FrequentGameData)
    case failure(RequestError)
}

struct GameRequest {
    static func searchMine(completion: @escaping (GamesPublicResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "games/mine")
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = data else {
                switch httpResponse.statusCode {
                case 401: completion(.failure(.unauthorised))
                case 404: completion(.failure(.notFound))
                default: completion(.failure(.other))
                }
                return
            }
            do {
                let games = try JSONDecoder().decode([Game.Public].self, from: jsonData)
                completion(.success(games))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    static func search(by gameID: UUID, setAccepted: Bool, completion: @escaping (GameDataResult) -> Void) {
        let URLPostfix = setAccepted ? "/accept" : ""
        let resourceURL = URL(string: K.Server.name + "games/"+gameID.uuidString+URLPostfix)
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = setAccepted ? "POST" : "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = data else {
                switch httpResponse.statusCode {
                case 401: completion(.failure(.unauthorised))
                case 404: completion(.failure(.notFound))
                default: completion(.failure(.other))
                }
                return
            }
            do {
                let gameData = try JSONDecoder().decode(GameData.self, from: jsonData)
                completion(.success(gameData))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    
    static func reject(gameID: UUID, completion: @escaping (OkResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "games/"+gameID.uuidString+"/reject")
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            switch httpResponse.statusCode {
            case 200: completion(.success)
            case 401: completion(.failure(.unauthorised))
            case 404: completion(.failure(.notFound))
            default: completion(.failure(.other))
            }
            return
        }
        dataTask.resume()
    }
    
    static func create(_ gameData: GameData, completion: @escaping (GameIDResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "games")
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try! JSONEncoder().encode(gameData)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = data else {
                switch httpResponse.statusCode {
                case 401: completion(.failure(.unauthorised))
                case 404: completion(.failure(.notFound))
                default: completion(.failure(.other))
                }
                return
            }
            do {
                let gameUUIDOnly = try JSONDecoder().decode(Game.UUIDOnly.self, from: jsonData)
                completion(.success(gameUUIDOnly.gameID))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    
    static func update(for gameID: UUID, gameData: GameData, completion: @escaping (OkResult) -> Void) {
        let string = K.Server.name + "games/"+gameID.uuidString+"/update"
        let resourceURL = URL(string: string)
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try! JSONEncoder().encode(gameData)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            switch httpResponse.statusCode {
            case 200: completion(.success)
            case 401: completion(.failure(.unauthorised))
            case 404: completion(.failure(.notFound))
            default: completion(.failure(.other))
            }
        }
        dataTask.resume()
    }
    
    static func updateFrequent(for gameID: UUID, frequentGameData: FrequentGameData, completion: @escaping (OkResult) -> Void) {
        let string = K.Server.name + "games/"+gameID.uuidString+"/updatefrequent"
        let resourceURL = URL(string: string)
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try! JSONEncoder().encode(frequentGameData)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            switch httpResponse.statusCode {
            case 200: completion(.success)
            case 401: completion(.failure(.unauthorised))
            case 404: completion(.failure(.notFound))
            default: completion(.failure(.other))
            }
        }
        dataTask.resume()
    }
    
    static func getPlayersStatus(gameID: UUID, completion: @escaping (PlayerStatusResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "games/"+gameID.uuidString+"/players")
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = data else {
                switch httpResponse.statusCode {
                case 401: completion(.failure(.unauthorised))
                case 404: completion(.failure(.notFound))
                default: completion(.failure(.other))
                }
                return
            }
            do {
                let playersStatus = try JSONDecoder().decode([PlayerStatus].self, from: jsonData)
                completion(.success(playersStatus))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    
    static func get(gameID: UUID, completion: @escaping (GameDataResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "games/"+gameID.uuidString)
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = data else {
                switch httpResponse.statusCode {
                case 401: completion(.failure(.unauthorised))
                case 404: completion(.failure(.notFound))
                default: completion(.failure(.other))
                }
                return
            }
            do {
                let gameData = try JSONDecoder().decode(GameData.self, from: jsonData)
                completion(.success(gameData))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    
    static func getFrequent(gameID: UUID, completion: @escaping (FrequentGameDataResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "games/"+gameID.uuidString+"/frequent")
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = data else {
                switch httpResponse.statusCode {
                case 401: completion(.failure(.unauthorised))
                case 404: completion(.failure(.notFound))
                default: completion(.failure(.other))
                }
                return
            }
            do {
                let frequentGameData = try JSONDecoder().decode(FrequentGameData.self, from: jsonData)
                completion(.success(frequentGameData))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    static func delete(gameID: UUID, completion: @escaping (OkResult) -> Void) {
        let string = K.Server.name + "games/"+gameID.uuidString
        let resourceURL = URL(string: string)
        var urlRequest = URLRequest(url: resourceURL!)
        guard let token = Auth().token else {
            completion(.failure(.unauthorised))
            return
        }
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            switch httpResponse.statusCode {
            case 200: completion(.success)
            case 401: completion(.failure(.unauthorised))
            case 404: completion(.failure(.notFound))
            default: completion(.failure(.other))
            }
        }
        dataTask.resume()
    }
}

struct PlayerStatus: Codable {
    var playerID: UUID
    var accepted: Bool
    var lastTimeInGame: String
    
    var inGame: Bool {
        guard let date = lastTimeInGame.convertFromZ() else { return false }
        return -date.timeIntervalSinceNow < K.Server.Time.checkOffline
    }
}

struct FrequentGameData: Codable {
    var explainTime: String
    var turn: Int
    var guessedThisTurn: Int
    
    var timeFromExplain: Int? {
        //guard let time = explainTime?.timeIntervalSinceNow else { return nil }
        let time = -Int(explainTime.convertFromZ()!.timeIntervalSinceNow)
        return ((time < 0) || (time > 60)) ? nil : time
    }
}

