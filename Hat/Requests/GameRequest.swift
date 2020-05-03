import Foundation

enum GamesPublicResult {
    case success([Game.Public])
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
}
