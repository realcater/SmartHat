//
//  UIView+extension.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 30.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

extension UIView {
    func makeAllButtonsRound() {
        for case let button as UIButton in self.subviews {
            button.makeRounded()
        }
    }
    func setForAllImages(tintColor: UIColor) {
        for case let imageView as UIImageView in self.subviews {
            imageView.tintColor = tintColor
        }
    }
}
