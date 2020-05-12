import Foundation

enum UserPublicResult {
    case success(User.Public)
    case failure(RequestError)
}

enum UserPublicResults {
    case success([User.Public])
    case failure(RequestError)
}

enum UserTimeResult {
    case success(UserTime)
    case failure(RequestError)
}


struct UserRequest {
    static func search(by userID: UUID?, completion: @escaping (UserPublicResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "users/"+userID!.uuidString)
        var urlRequest = URLRequest(url: resourceURL!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
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
                let userPublic = try JSONDecoder().decode(User.Public.self, from: jsonData)
                completion(.success(userPublic))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    
    static func search(with searchRequestData: SearchRequestData, completion: @escaping (UserPublicResults) -> Void) {
        let resourceURL = URL(string: K.Server.name + "users/search")
        var urlRequest = URLRequest(url: resourceURL!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try! JSONEncoder().encode(searchRequestData)
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
                let usersPublic = try JSONDecoder().decode([User.Public].self, from: jsonData)
                completion(.success(usersPublic))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }

    static func create(_ user: User, completion: @escaping (UserPublicResult) -> Void) {
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
                        print(errorRespond.reason)
                        completion(.failure(.other))
                    }
                }
                catch {
                    completion(.failure(.other))
                }
            }
        }
        dataTask.resume()
    }

    static func confirmOnline(completion: @escaping (OkResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "users/online")
        var urlRequest = URLRequest(url: resourceURL!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
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
    
    static func getLastTimeOnline(userID: UUID?, completion: @escaping (UserTimeResult) -> Void) {
        let resourceURL = URL(string: K.Server.name + "users/"+userID!.uuidString+"/online")
        var urlRequest = URLRequest(url: resourceURL!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
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
                let userTime = try JSONDecoder().decode(UserTime.self, from: jsonData)
                completion(.success(userTime))
            } catch {
                completion(.failure(.other))
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
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
