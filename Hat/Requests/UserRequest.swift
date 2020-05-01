import Foundation

enum UserPublicResult {
    case success(User.Public)
    case failure
}

enum UserCreateResult {
    case success(User.Public)
    case failureDuplicate
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
    
    func searchByID(_ userID: UUID?, completion: @escaping (UserPublicResult) -> Void) {
        var urlRequest = URLRequest(url: resourceURL)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                completion(.failure)
                return
            }
            do {
                let userPublic = try JSONDecoder().decode(User.Public.self, from: jsonData)
                completion(.success(userPublic))
            } catch {
                completion(.failure)
                print("Can't parse JSON answer")
            }
        }
        dataTask.resume()
    }
    
    func create(_ user: User, completion: @escaping (UserCreateResult) -> Void) {
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(user)
            urlRequest.setValue("Bearer \(Environment.appKey)", forHTTPHeaderField: "Authorization")
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let _ = response as? HTTPURLResponse, let jsonData = data else {
                    completion(.failureOther)
                    print("1st  failure")
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
        } catch {
            completion(.failureOther)
            print("3d  failure")
        }
    }
}
