//
//  Timer+extension.swift
//  Hat
//
//  Created by Realcater on 09.05.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

extension Timer {
    func createRepeated(timeInterval: Int, selector: Selector) -> Timer {
        let timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: selector,
                                     userInfo: nil,
                                    repeats: true)
        timer.tolerance = 0.1
        return timer
    }
}
