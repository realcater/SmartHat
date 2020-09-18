import Foundation

class Helper {
    static func move2(word: Word, from: [Word], to: [Word]) -> ([Word],[Word]) {
        guard let index = from.firstIndex(of: word) else {
            return (from, to)
        }
        var fromResult = from
        var toResult = to
        fromResult.remove(at: index)
        toResult.append(word)
        return (fromResult,toResult)
    }
    static func getPlistFileName(_ fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.allDomainsMask, true)
        return paths[0].appending("/"+fileName+".plist")
    }
    static func generatePassword() -> String {
        let length = 12
        let pswdChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        return String((0..<length).compactMap{ _ in pswdChars.randomElement() })
        
    }
    
    static func save<T>(_ object: T, to fileName: String) where T: Codable {
        let plistFileName = getPlistFileName(fileName)
        let encodedData = try! JSONEncoder().encode(object)
                NSKeyedArchiver.archiveRootObject(encodedData, toFile: plistFileName)
    }
    static func load<T>(from fileName: String) -> T? where T: Codable {
        let plistFileName = getPlistFileName(fileName)
        if let encodedData = NSKeyedUnarchiver.unarchiveObject(withFile: plistFileName) as? Data, let object = try? JSONDecoder().decode(T.self, from: encodedData) {
            return object
        } else {
            return nil
        }
    }
}
