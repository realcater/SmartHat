//
//  HelpViewController.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 25.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class HelpVC: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let pagesForLoad : [Int] = [0,1,2,3,4,5,7]
    
    @objc private func singleTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.ended) {
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: K.Delays.pageChangeViaPageControl, delay: 0,
                         options: [.curveEaseInOut], animations: {
                            self.scrollView.contentOffset = CGPoint(
                                x: self.scrollView.bounds.size.width *
                                    CGFloat(sender.currentPage), y: 0)
        },
                         completion: nil)
    }
    private func setPageControl(numberOfPages: Int) {
        pageControl.pageIndicatorTintColor = K.Colors.foregroundDarker
        pageControl.currentPageIndicatorTintColor = K.Colors.foregroundLighter
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
    }
    
    private func addViews(to viewName: UIView, from nibName: String) {
        let width = scrollView.bounds.size.width
        let height = scrollView.bounds.size.height
        let margin = K.Margins.helpScreen
        
        let viewNib = UINib(nibName: nibName, bundle: nil)
        let viewNibArray = viewNib.instantiate(withOwner: scrollView, options: nil)
        
        for (i,page) in pagesForLoad.enumerated() {
            let viewNib = viewNibArray[page]
            let frame = CGRect (x: margin+CGFloat(i)*width, y: margin, width: width-2*margin, height: height-2*margin)
            if let viewNib = viewNib as? UIView {
                viewNib.frame = frame
                viewNib.makeAllButtonsRound()
                viewNib.setForAllImages(tintColor: K.Colors.foreground)
                viewName.addSubview(viewNib)
            }
        }
    }
    private func setScrollViewSize(numberOfPages: Int) {
        let width = scrollView.bounds.size.width
        let height = scrollView.bounds.size.height
        scrollView.contentSize = CGSize(width: width * CGFloat(numberOfPages), height: height)
    }
    // MARK:- Override class func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTaps(singleTapAction: #selector(singleTap))
        popupView.layer.cornerRadius = K.windowsCornerRadius
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        view.layoutIfNeeded()

        addViews(to: scrollView, from: "help")
        setScrollViewSize(numberOfPages: pagesForLoad.count)
        setPageControl(numberOfPages: pagesForLoad.count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}

extension HelpVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2)
            / width)
        pageControl.currentPage = page
    }
}
