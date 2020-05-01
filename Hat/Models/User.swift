import Foundation

class User: Codable {
    internal init(id: UUID, name: String, password: String) {
        self.id = id
        self.name = name
        self.password = password
    }
    var id: UUID
    var name: String
    var password: String
    
    class Public: Codable {
        var id: UUID?
        var name: String
        
        init(id: UUID?, name: String) {
            self.id = id
            self.name = name
        }
    }
}
