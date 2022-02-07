//
//  UIScrollerView+HF.swift
//  HFKit
//
//  Created by helfy on 2021/12/31.
//
import UIKit
extension UIScrollView {
    func scrollerDidToBottom() -> Bool {
        let dif = self.contentSize.height - self.frame.size.height - self.contentInset.bottom
        let canMove = self.contentOffset.y - dif >= -1
        return canMove
    }
    
    func scrollerDidToTop() -> Bool {
        self.contentOffset.y <= -self.contentInset.top
    }
    
    func scrollToBottom(animated:Bool = false) {
        if animated {
            self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height), animated: animated)
        } else {
            self.contentOffset = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height + self.contentInset.bottom + self.contentInset.top)
        }
//        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height), animated: animated)
  
    }
    
    func scrollToTop(animated:Bool = false) {
        self.setContentOffset(CGPoint(x: 0, y: -self.contentInset.top), animated: animated)
    }
    
}

