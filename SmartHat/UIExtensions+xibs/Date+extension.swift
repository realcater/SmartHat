//
//  Date+extension.swift
//  Hat
//
//  Created by Realcater on 12.05.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

extension Date {
    func convertTo(use dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss'Z'") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = (dateFormat == "yyyy-MM-dd'T'HH:mm:ss'Z'") ? NSTimeZone(name: "UTC") as TimeZone? : NSTimeZone.local
        return dateFormatter.string(from: self)
    }
}
