import Foundation

enum UserSearchResult {
    case success(User.Public)
    case notFound
    case noConnection
    case failureOther
}

enum UserCreateResult {
    case success(User.Public)
    case failureDuplicate
    case noConnection
    case failureOther
}

struct UserRequest {
    let resourceURL: URL
    let userName: String?
    
    init(userID: UUID? = nil, userName: String? = nil) {
        let baseResourceString = K.Server.name + "users/"
        var resourceString: String {
            if let userID = userID {
                return baseResourceString + userID.uuidString
            } else if userName != nil {
                return baseResourceString + "search"
            } else {
                return baseResourceString
            }
        }
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        self.resourceURL = resourceURL
        self.userName = userName
    }
    
    func searchByID(_ userID: UUID?, completion: @escaping (UserSearchResult) -> Void) {
        var urlRequest = URLRequest(url: resourceURL)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.noConnection)
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = data else {
                if httpResponse.statusCode == 404 {
                    completion(.notFound)
                } else {
                    completion(.failureOther)
                }
                return
            }
            do {
                let userPublic = try JSONDecoder().decode(User.Public.self, from: jsonData)
                completion(.success(userPublic))
            } catch {
                completion(.failureOther)
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    
    func create(_ user: User, completion: @escaping (UserCreateResult) -> Void) {
        var urlRequest = URLRequest(url: resourceURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try! JSONEncoder().encode(user)
        urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let _ = response as? HTTPURLResponse else {
               completion(.noConnection)
               return
            }
            guard let jsonData = data else {
                completion(.failureOther)
                return
            }
            do {
                let userPublic = try JSONDecoder().decode(User.Public.self, from: jsonData)
                completion(.success(userPublic))
            } catch {
                do {
                    let errorRespond = try JSONDecoder().decode(ErrorRespond.self, from: jsonData)
                    if errorRespond.reason.prefix(K.Server.duplicateNameRespondPrefixLength-1) == K.Server.duplicateNameRespondPrefix {
                        completion(.failureDuplicate)
                    } else {
                        print(errorRespond.reason)
                        completion(.failureOther)
                    }
                }
                catch {
                    completion(.failureOther)
                }
            }
        }
        dataTask.resume()
    }
}
