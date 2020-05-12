//
//  Date+extension.swift
//  Hat
//
//  Created by Realcater on 12.05.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

extension Date {
    func convertTo(use dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: self)
    }
}
