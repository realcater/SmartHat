import Foundation
import UIKit
import SwiftKeychainWrapper

enum AuthResult {
  case success
  case failure(RequestError)
}

class Auth {
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "token")
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "token")
            }
        }
    }
    var expirationDateString: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "expirationDate")
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "expirationDate")
            }
        }
    }
    var expirationDate: Date? {
        let expirationDate = expirationDateString?.convertFromZ()
        return expirationDate
    }
    var id: UUID? {
        get {
            if let uuidString = KeychainWrapper.standard.string(forKey: "id") {
                return UUID(uuidString: uuidString)
            } else { return nil }
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue.uuidString, forKey: "id")
            }
        }
    }
    var name: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "name")
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "name")
            }
        }
    }
    var password: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "password")
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "password")
            }
        }
    }

    func login(completion: @escaping (AuthResult) -> Void) {
        guard let name = name, let password = password, let loginString = "\(name):\(password)".data(using: .utf8)?.base64EncodedString() else {
          fatalError()
        }
        let resourceURL = URL(string: K.Server.name + "users/login")
        var loginRequest = URLRequest(url: resourceURL!)

        loginRequest.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        loginRequest.httpMethod = "POST"

        let dataTask = URLSession.shared.dataTask(with: loginRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noConnection))
                return
            }
            guard httpResponse.statusCode == 200, let jsonData = data else {
                completion(.failure(.unauthorised))
                return
            }
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
                self.token = loginResponse.jwtToken
                self.expirationDateString = loginResponse.expirationDate
                print("==== \(Date()): LOGIN SUCCESS ====")
                print("==== expirationDate: \(self.expirationDateString!) ====")
                completion(.success)
            } catch {
                completion(.failure(.other))
            }
        }
        dataTask.resume()
    }
}

struct LoginResponse: Codable {
    let name: String
    let id: UUID
    let jwtToken: String
    let expirationDate: String
}
