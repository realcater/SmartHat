import Foundation

struct UserRequest {
    static func create(_ user: User, completion: @escaping (OkResult) -> Void) {
        print("========== create ===========")
        sendRequestIn(
                        stringUrl: "users",
                        httpMethod: "POST",
                        dataIn: user,
                        useAppToken: true,
                        completion: completion)
        }
    static func changeName(_ updateUserData: UpdateUserData, completion: @escaping (OkResult) -> Void) {
        sendRequestIn(
                        stringUrl: "users/changeName",
                        httpMethod: "POST",
                        dataIn: updateUserData,
                        completion: completion)
        }
    static func get(userID: UUID?, completion: @escaping (Result<User.Public>) -> Void) {
        print("========== get ===========")
        sendRequestOut(
                    stringUrl: "users/"+userID!.uuidString,
                    httpMethod: "GET",
                    useAppToken: true,
                    completion: completion)
    }
    static func search(with searchRequestData: SearchRequestData, completion: @escaping (Result<[User.Public]>) -> Void) {
        print("========== search ===========")
        sendRequestInOut(
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
        sendRequestOut(
                    stringUrl: "users/"+userID!.uuidString+"/online",
                    httpMethod: "POST",
                    completion: completion)
        }
    static func loadSettings(completion: @escaping (Result<ClientSettings>) -> Void) {
        print("========== loadSettings ===========")
        sendRequestOut(
                    stringUrl: "settings",
                    httpMethod: "GET",
                    useAppToken: true,
                    completion: completion)
    }
}

struct SearchRequestData: Codable {
    let text: String
    let maxResultsQty: Int
}

struct UpdateUserData: Codable {
    let newName: String
}

struct UserTime: Codable {
    let id: UUID
    let lastTimeOnline: String
}
