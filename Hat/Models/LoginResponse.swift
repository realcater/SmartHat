import Foundation

struct LoginResponse: Codable {
    let name: String
    let id: UUID
    let jwtToken: String
}
