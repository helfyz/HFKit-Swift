//
//  LinkageManger.swift
//  HFKit
//
//  Created by helfy on 2021/12/13.
//

import UIKit

class LinkageManger: NSObject {
    var outer: UIScrollView?
    var inner: UIScrollView?
    
    
    func scrollerDidScrollToBottom(scroller:UIScrollView) -> Bool {
        let dif = scroller.contentSize.height - scroller.frame.size.height - scroller.contentInset.bottom
        let canMove = scroller.contentOffset.y - dif >= -1
        return canMove
    }
    
    func scrollerDidScrollToTop(scroller:UIScrollView) -> Bool {
        scroller.contentOffset.y <= -scroller.contentInset.top
    }
    
    func scrollToBottom(scroller:UIScrollView) {
        scroller.contentOffset = CGPoint(x: 0, y: scroller.contentSize.height - scroller.frame.size.height)
    }
    
    func scrollToTop(scroller:UIScrollView) {
        scroller.contentOffset = CGPoint(x: 0, y: -scroller.contentInset.top)
    }
    
//    func adjustScrollViewToTargetContentInsetIfNeeded(scroller: UIScrollView, insets:UIEdgeInsets) {
//        insets.
//    }
    
    func scrollViewDidScroll(scroller:UIScrollView) {
        switch scroller {
            case outer:
                guard let inner = inner else {
                    return
                }
                guard let outer = outer else {
                    return
                }
                let innerToTop = scrollerDidScrollToTop(scroller: inner)
                if innerToTop {
                    let isOuterToBottom = scrollerDidScrollToBottom(scroller: outer)
                    let isOuterToTop = scrollerDidScrollToTop(scroller: outer)
                    if isOuterToBottom {
                        scrollToBottom(scroller: outer)
                    } else if isOuterToTop {
                        scrollToTop(scroller: outer)
                    }
                } else {
                    
                }
                break
            case inner:
                break
              
            default:break
        }
     }
}
