class Helper {
    static func move(str: String, from: inout [String], to: inout [String]) {
        if let index = from.index(of: str) {
            from.remove(at: index)
            to.append(str)
        }
    }
}
