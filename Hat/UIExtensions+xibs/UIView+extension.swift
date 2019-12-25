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
        for case let button as MyButton in self.subviews {
            button.makeRounded()
        }
    }
    func setForAllImages(tintColor: UIColor) {
        for case let imageView as UIImageView in self.subviews {
            imageView.tintColor = tintColor
        }
    }
    func setForAllLabels(withFontName fontName: String, fontSize: CGFloat) {
        for case let label as UILabel in self.subviews {
            if label.font.fontName == fontName {
                label.font = UIFont(descriptor: label.font.fontDescriptor, size: fontSize)
            }
        }
    }
    func setConstraint(identifier: String, size: CGFloat) {
        for constraint in self.constraints {
            if constraint.identifier == identifier {
                constraint.constant = size
            }
        }
    }
    func setBackgroundImage(named: String, alpha: CGFloat) {
        if let image = UIImage(named: named) {
            let backgroundImageView = UIImageView(frame: self.bounds)
            backgroundImageView.image = image
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.alpha = alpha
            insertSubview(backgroundImageView, at: 0)
        }
    }
}
