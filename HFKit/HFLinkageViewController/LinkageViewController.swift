//
//  LinkageViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//

import UIKit

protocol LinkageChildViewControllerProtocol:NSObjectProtocol {
    var linkpageDelgate:LinkageManger? {get set}
    var scroller:UIScrollView? {get}
    func scrollViewDidScroll(scroller:UIScrollView)
    // 页面出现 & 消失
    func linkageControllerWillAppear(animation:Bool)
    func linkageControllerDidAppear(animation:Bool)
    func linkageControllerWillDisappear(animation:Bool)
    func linkageControllerDidDisappear(animation:Bool)
    //linkpageVc的滚动 同步到 vc中，用于外部滚动的时候，内部可能需要对偏移做一些处理
    func outerScrollViewDidScroll(scroller:UIScrollView)
    func reload()
}


class LinkageScroller:UIScrollView {
    //设置允许手势与其他手势共存
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer
       otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UICollectionView {
            return false
        }
        return true
   }
    
}

class LinkageViewController: UIViewController {
    var firstCanScrollerBounds: Bool = false
    var fullScreen : Bool = false // 内容全屏，不做安全区的约束
    var headerFixedHeight: CGFloat = 0 // 顶部区域悬浮高度，默认为titleView的高度
    var headerContainerView: UIView? // 头部容器
    var contentView : UIView?
    var pageHeaderView : UIView?
    var collectionView : UICollectionView? // ChildVc 左右滑动的承载容器
    var pageModels: [LinkageModelProtocol] = []
  
    var curIndex: Int = 0
    var linkpageManger: LinkageManger = LinkageManger()
    var headerTotalHeight: CGFloat = 0 // 顶部区域总高度，有改变的时候，外部需要提前计算好，包括titleView的高度，默认为titleView的高度
    
    var bottomSpace: CGFloat = 0  // 底部留空
    lazy var contentScroller : UIScrollView = {
        let scroller = LinkageScroller()
        scroller.delegate = self
        scroller.bounces = false
        scroller.showsVerticalScrollIndicator = false
        scroller.showsHorizontalScrollIndicator = false
        scroller.backgroundColor = .clear
        view.addSubview(scroller)
        
        scroller.translatesAutoresizingMaskIntoConstraints = false
        if(fullScreen) {
            NSLayoutConstraint.activate([
                scroller.topAnchor.constraint(equalTo: view.topAnchor),
                scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]);
        } else {
            NSLayoutConstraint.activate([
                scroller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scroller.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scroller.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                scroller.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            ]);
        }
        return scroller
    }()
   
    lazy var titleView:LinkageTitleViewProtocol = {
       let view = LinkageTitleView()
        return view
        
    }()
    deinit {
        for model in pageModels {
            model.viewController?.linkpageDelgate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        
    }
    

}

extension LinkageViewController: UIScrollViewDelegate {
    
}
