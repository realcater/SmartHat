//
//  UIViewController+extension.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 31.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

extension UIViewController {
    func addTaps(for tappedView: UIView? = nil, singleTapAction: Selector? = nil, doubleTapAction: Selector? = nil, anySwipeAction: Selector? = nil) {
        let tappedView: UIView = tappedView ?? self.view //if ==nil than we use default view of VC
        var singleTap: UITapGestureRecognizer!
        var doubleTap: UITapGestureRecognizer!
        var anySwipe: UISwipeGestureRecognizer!
        
        if let singleTapAction = singleTapAction {
            singleTap = UITapGestureRecognizer(target: self, action: singleTapAction)
            singleTap.numberOfTapsRequired = 1
        }
        if let doubleTapAction = doubleTapAction {
            doubleTap = UITapGestureRecognizer(target: self, action: doubleTapAction)
            doubleTap.numberOfTapsRequired = 2
        }
        if let anySwipeAction = anySwipeAction {
            anySwipe = UISwipeGestureRecognizer(target: self, action: anySwipeAction)
            print("===", anySwipe.direction)
        }

        if let singleTap = singleTap, let doubleTap = doubleTap  {
            singleTap.require(toFail: doubleTap)
        }
        
        if let singleTap = singleTap { tappedView.addGestureRecognizer(singleTap) }
        if let doubleTap = doubleTap { tappedView.addGestureRecognizer(doubleTap) }
        if let anySwipe = anySwipe { tappedView.addGestureRecognizer(anySwipe) }
        
        tappedView.isUserInteractionEnabled = true
    }
}
