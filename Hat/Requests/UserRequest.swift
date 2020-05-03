import Foundation

enum UserPublicResult {
    case success(User.Public)
    case failure(RequestError)
}

struct UserRequest {
    static func search(_ userID: UUID?, completion: @escaping (UserPublicResult) -> Void) {
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
                if httpResponse.statusCode == 401 {
                    completion(.failure(.unauthorised))
                } else if httpResponse.statusCode == 404 {
                    completion(.failure(.notFound))
                } else {
                    completion(.failure(.other))
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
}
