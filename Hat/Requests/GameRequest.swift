import Foundation

enum GamesPublicResult {
    case success([GameDBItem.Public])
    case failure(RequestError)
}

enum GameResult {
    case success(Game)
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
                if httpResponse.statusCode == 401 {
                    completion(.failure(.unauthorised))
                } else {
                    completion(.failure(.other))
                }
                return
            }
            do {
                let games = try JSONDecoder().decode([GameDBItem.Public].self, from: jsonData)
                completion(.success(games))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
                print(token)
            }
        }
        dataTask.resume()
    }
    static func search(by gameID: UUID, completion: @escaping (GameResult) -> Void) {
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
                let game = try JSONDecoder().decode(Game.self, from: jsonData)
                completion(.success(game))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
                print(token)
            }
        }
        dataTask.resume()
    }
}
