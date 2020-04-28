import Foundation

class User {
    internal init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    var id: UUID
    var name: String
}
