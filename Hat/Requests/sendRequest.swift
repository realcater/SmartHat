import Foundation

enum Result<DataTypeOut> {
    case success(DataTypeOut)
    case failure(RequestError)
}

enum OkResult {
    case success
    case failure(RequestError)
}



func sendRequestInOut<DataTypeIn, DataTypeOut>(stringUrl: String, httpMethod: String, dataIn: DataTypeIn, useAppToken: Bool = false, completion: @escaping (Result<DataTypeOut>) -> Void) where DataTypeIn: Codable, DataTypeOut: Codable {
    
    let resourceURL = URL(string: K.Server.name + stringUrl)
    var urlRequest = URLRequest(url: resourceURL!)
    
    getToken(useAppToken: useAppToken) { token, error in
        guard error == nil else {
            completion(.failure(error!))
            return
        }
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try! JSONEncoder().encode(dataIn)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { dataOut, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = dataOut else {
                switch httpResponse.statusCode {
                case 401: completion(.failure(.unauthorised))
                case 503: completion(.failure(.serverUnavailable))
                case 404: completion(.failure(.notFound))
                case 226: completion(.failure(.gameEnded))
                default: completion(.failure(.other))
                }
                return
            }
            do {
                let dataOut = try JSONDecoder().decode(DataTypeOut.self, from: jsonData)
                completion(.success(dataOut))
            } catch {
                completion(.failure(.JSONParseError))
            }
        }
        dataTask.resume()
    }
}



func sendRequestOut<DataTypeOut>(stringUrl: String, httpMethod: String, useAppToken: Bool = false, completion: @escaping (Result<DataTypeOut>) -> Void) where DataTypeOut: Codable {
    
    let resourceURL = URL(string: K.Server.name + stringUrl)
    var urlRequest = URLRequest(url: resourceURL!)
    
    getToken(useAppToken: useAppToken) { token, error in
        guard error == nil else {
            completion(.failure(error!))
            return
        }
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { dataOut, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = dataOut else {
                switch httpResponse.statusCode {
                case 401: completion(.failure(.unauthorised))
                case 503: completion(.failure(.serverUnavailable))
                case 404: completion(.failure(.notFound))
                case 226: completion(.failure(.gameEnded))
                default: completion(.failure(.other))
                }
                return
            }
            do {
                let dataOut = try JSONDecoder().decode(DataTypeOut.self, from: jsonData)
                completion(.success(dataOut))
            } catch {
                completion(.failure(.JSONParseError))
            }
        }
        dataTask.resume()
    }
}


func sendRequestIn<DataTypeIn>(stringUrl: String, httpMethod: String, dataIn: DataTypeIn, useAppToken: Bool = false, completion: @escaping (OkResult) -> Void) where DataTypeIn: Codable {
    
    let resourceURL = URL(string: K.Server.name + stringUrl)
    var urlRequest = URLRequest(url: resourceURL!)
    
    getToken(useAppToken: useAppToken) { token, error in
        guard error == nil else {
            completion(.failure(error!))
            return
        }
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = try! JSONEncoder().encode(dataIn)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            switch httpResponse.statusCode {
                case 200: completion(.success)
                case 503: completion(.failure(.serverUnavailable))
                case 401: completion(.failure(.unauthorised))
                case 404: completion(.failure(.notFound))
                case 409: completion(.failure(.duplicate))
                case 226: completion(.failure(.gameEnded))
              default: completion(.failure(.other))
              }
        }
        dataTask.resume()
    }
}

func sendRequest(stringUrl: String, httpMethod: String, completion: @escaping (OkResult) -> Void) {
    
    let resourceURL = URL(string: K.Server.name + stringUrl)
    var urlRequest = URLRequest(url: resourceURL!)

    getToken(useAppToken: false) { token, error in
        guard error == nil else {
            completion(.failure(error!))
            return
        }
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            switch httpResponse.statusCode {
                case 200: completion(.success)
                case 503: completion(.failure(.serverUnavailable))
                case 401: completion(.failure(.unauthorised))
                case 404: completion(.failure(.notFound))
                case 226: completion(.failure(.gameEnded))
                default: completion(.failure(.other))
            }
        }
        dataTask.resume()
    }
}

func getToken(useAppToken: Bool, completion: @escaping (String, RequestError?) -> Void) {
    guard !useAppToken else {
        completion(Environment.appKey, nil)
        return
    }
    if let expirationDate = Auth().expirationDate, expirationDate > Date() {
        completion(Auth().token!, nil)
    } else {
        Auth().login() { result in
            switch result {
            case .success:
                completion(Auth().token!, nil)
            case .failure(let error):
                completion("", error)
            }
        }
    }
}

