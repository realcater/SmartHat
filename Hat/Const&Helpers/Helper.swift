import Foundation

class Helper {
    static func move(str: String, from: inout [String], to: inout [String]) {
        if let index = from.firstIndex(of: str) {
            from.remove(at: index)
            to.append(str)
        }
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

    static func getStringTime(from DateTime: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = dateFormatter.date(from: DateTime)
        
        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: date!)
    }
}
