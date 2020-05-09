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
                print(token)
            }
        }
        dataTask.resume()
    }
    static func search(by gameID: UUID, completion: @escaping (GameDataResult) -> Void) {
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
                print(token)
            }
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
                print(token)
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
                print(token)
            }
        }
        dataTask.resume()
    }
}

struct PlayerStatus: Codable {
    var playerID: UUID
    var accepted: Bool
}
