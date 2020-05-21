import Foundation

class Helper {
    static func move(str: String, from: inout [String], to: inout [String]) {
        if let index = from.firstIndex(of: str) {
            from.remove(at: index)
            to.append(str)
        }
    }
    static func move2(str: String, from: [String], to: [String]) -> ([String],[String]) {
        guard let index = from.firstIndex(of: str) else {
            return (from, to)
        }
        var fromResult = from
        var toResult = to
        fromResult.remove(at: index)
        toResult.append(str)
        return (fromResult,toResult)
    }
    
    static func plistFileName(_ fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true)
        return paths[0].appending("/"+fileName+".plist")
    }
    static func generatePassword() -> String {
        let length = 12
        let pswdChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        return String((0..<length).compactMap{ _ in pswdChars.randomElement() })
        
    }
}
