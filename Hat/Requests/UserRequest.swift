import Foundation

struct UserRequest {
    static func create(_ user: User, completion: @escaping (Result<User.Public>) -> Void) {
        let resourceURL = URL(string: K.Server.name + "users")
        var urlRequest = URLRequest(url: resourceURL!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try! JSONEncoder().encode(user)
        urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let _ = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
               return
            }
            guard let jsonData = data else {
                completion(.failure(.other))
                return
            }
            do {
                let userPublic = try JSONDecoder().decode(User.Public.self, from: jsonData)
                completion(.success(userPublic))
            } catch {
                do {
                    let errorRespond = try JSONDecoder().decode(ErrorResponse.self, from: jsonData)
                    if errorRespond.reason.prefix(K.Server.duplicateNameRespondPrefixLength) == K.Server.duplicateNameRespondPrefix {
                        completion(.failure(.duplicate))
                    } else {
                        completion(.failure(.other))
                    }
                }
                catch {
                    completion(.failure(.JSONParseError))
                }
            }
        }
        dataTask.resume()
    }
    static func get(userID: UUID?, completion: @escaping (Result<User.Public>) -> Void) {
        sendRequest(
                    stringUrl: "users/"+userID!.uuidString,
                    httpMethod: "GET",
                    useAppToken: true,
                    completion: completion)
    }
    static func search(with searchRequestData: SearchRequestData, completion: @escaping (Result<[User.Public]>) -> Void) {
        sendRequest(
                    stringUrl: "users/search",
                    httpMethod: "POST",
                    dataIn: searchRequestData,
                    completion: completion)
    }
    static func confirmOnline(completion: @escaping (OkResult) -> Void) {
        sendRequest(
                    stringUrl: "users/online",
                    httpMethod: "POST",
                    completion: completion)
    }
    static func getLastTimeOnline(userID: UUID?, completion: @escaping (Result<UserTime>) -> Void) {
        sendRequest(
                    stringUrl: "users/"+userID!.uuidString+"/online",
                    httpMethod: "POST",
                    completion: completion)
        }
}

struct SearchRequestData: Codable {
    let text: String
    let maxResultsQty: Int
}

struct ErrorResponse: Codable {
    var error: Bool
    var reason: String
}

struct UserTime: Codable {
    let id: UUID
    let lastTimeOnline: String
}
