//
//  imageView+extension.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 31.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

typealias noArgsFunc = () -> Void

class UIRotatedImageView: UIImageView {
    func rotation(for circlesQty:Double, onCompletion action: @escaping noArgsFunc) {
        let sectorsQty = 12.0
        let acceleration = 1.05
        var duration : Double = 5
        let rollsQty = Int(circlesQty*sectorsQty)
        var rollsFinished = 0
        for i in 0...rollsQty-1 {
            let angle = -CGFloat(i % Int(sectorsQty)+1)*CGFloat.pi*2.0/CGFloat(sectorsQty)
            UIView.animate(withDuration: duration, delay: 0.0, animations: {
                self.transform = CGAffineTransform(rotationAngle: angle)
            }, completion: { finished in
                rollsFinished+=1
                if finished, rollsFinished == rollsQty { //block with i==0 finishes last of all i=..
                    action()
                }
            })
            duration = duration / acceleration
        }
    }
}
