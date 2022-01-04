//
//  LinkageManager.swift
//  HFKit
//
//  Created by helfy on 2021/12/13.
//

import UIKit


class LinkageManager: NSObject {
    var outer: UIScrollView?
    var inner: UIScrollView?

    
    func scrollViewDidScroll(scroller:UIScrollView) {
        guard let inner = inner else {
            return
        }
        guard let outer = outer else {
            return
        }
        switch scroller {
            case outer:
            let innerToTop = inner.scrollerDidToTop()
                if innerToTop {
                    let isOuterToBottom = outer.scrollerDidToBottom()
                    let isOuterToTop = outer.scrollerDidToTop()
                    if isOuterToBottom {
                        outer.scrollToBottom()
                    } else if isOuterToTop {
                        outer.scrollToTop()
                    }
                } else {
                    outer.scrollToBottom()
                }
                break
            case inner:
            //外部到底
            let isOuterToBottom = outer.scrollerDidToBottom()
            if !isOuterToBottom {
                let isOuterToTop = outer.scrollerDidToTop()
                if !isOuterToTop {
                    inner.scrollToTop()
                }
            }
            break
            default:break
        }
     }
}
