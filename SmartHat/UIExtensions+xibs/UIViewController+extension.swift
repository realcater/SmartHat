//
//  UIViewController+extension.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 31.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

struct AlertButton {
    var text: String
    var action: () -> Void
}

extension UIViewController {
    func addTaps(for tappedView: UIView? = nil, singleTapAction: Selector? = nil, doubleTapAction: Selector? = nil, anySwipeAction: Selector? = nil, singleTapCancelsTouchesInView: Bool = true, delegate: UIGestureRecognizerDelegate? = nil) {
        let tappedView: UIView = tappedView ?? self.view //if ==nil than we use default view of VC
        var singleTap: UITapGestureRecognizer!
        var doubleTap: UITapGestureRecognizer!
        var anySwipe: UISwipeGestureRecognizer!
        
        if let singleTapAction = singleTapAction {
            singleTap = UITapGestureRecognizer(target: self, action: singleTapAction)
            singleTap.numberOfTapsRequired = 1
            if let delegate = delegate { singleTap.delegate = delegate }
        }
        if let doubleTapAction = doubleTapAction {
            doubleTap = UITapGestureRecognizer(target: self, action: doubleTapAction)
            doubleTap.numberOfTapsRequired = 2
            if let delegate = delegate { singleTap.delegate = delegate }
        }
        if let anySwipeAction = anySwipeAction {
            anySwipe = UISwipeGestureRecognizer(target: self, action: anySwipeAction)
            if let delegate = delegate { singleTap.delegate = delegate }
        }

        if let singleTap = singleTap, let doubleTap = doubleTap  {
            singleTap.require(toFail: doubleTap)
        }
        
        if let singleTap = singleTap { tappedView.addGestureRecognizer(singleTap) }
        if let doubleTap = doubleTap { tappedView.addGestureRecognizer(doubleTap) }
        if let anySwipe = anySwipe { tappedView.addGestureRecognizer(anySwipe) }
        
        tappedView.isUserInteractionEnabled = true
    }
    func showWarning(_ error: RequestError) {
        self.title = error.warning
    }
    func showWarning(_ text: String) {
        self.title = text
    }
    func showWarningOrTitle(_ error: RequestError?, _ title: String? = nil) {
        if let error = error {
            self.title = error.warning
        } else {
            self.title = title
        }
    }
    func showWarning(_ error: RequestError, in textView: UITextView) {
        textView.text = error.warning
        textView.isHidden = false
    }
    func showWarning(_ text: String, in textView: UITextView) {
        textView.text = text
        textView.isHidden = false
    }
    func hideWarning(in textView: UITextView) {
        textView.isHidden = true
    }
}
