//
//  LinkageViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//

import UIKit

@objc protocol LinkageChildViewControllerProtocol: NSObjectProtocol {
    var linkpageDelgate:LinkageManger? {get set}
    var scroller:UIScrollView? {get}
    @objc optional  func scrollViewDidScroll(scroller:UIScrollView)
    // 页面出现 & 消失
    @objc optional func linkageControllerWillAppear(animation:Bool)
    @objc optional func linkageControllerDidAppear(animation:Bool)
    @objc optional func linkageControllerWillDisappear(animation:Bool)
    @objc optional func linkageControllerDidDisappear(animation:Bool)
    //linkpageVc的滚动 同步到 vc中，用于外部滚动的时候，内部可能需要对偏移做一些处理
    @objc optional func outerScrollViewDidScroll(scroller:UIScrollView)
    @objc optional func reload()
    
}

class PageViewControllerCell: UICollectionViewCell {
    weak var viewController: LinkageChildViewControllerProtocol?
}
class LinkageScroller:UIScrollView,UIGestureRecognizerDelegate {
    
    //设置允许手势与其他手势共存
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
       otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if otherGestureRecognizer.view is UICollectionView {
//            return false
//        }
        return true
   }
}

class LinkageViewController: UIViewController {
    var firstCanScrollerBounds: Bool = false
    var fullScreen : Bool = false // 内容全屏，不做安全区的约束
    var headerFixedHeight: CGFloat = 0 // 顶部区域悬浮高度，默认为titleView的高度
    var headerContainerView: UIView? // 头部容器
    var pageHeaderView : UIView?
    fileprivate var _models: [LinkageModelProtocol] = []
    var pageModels:[LinkageModelProtocol] {
        get {
            _models
        }
    }
    var curIndex: Int = 0
    var linkpageManger: LinkageManger = LinkageManger()
    var headerTotalHeight: CGFloat = 0 // 顶部区域总高度，有改变的时候，外部需要提前计算好，包括titleView的高度，默认为titleView的高度
    
    var bottomSpace: CGFloat = 0  // 底部留空
    lazy var contentView : UIView = {
        let contentView = UIView()
        contentScroller.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo:  contentScroller.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentScroller.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentScroller.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentScroller.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: contentScroller.widthAnchor),
            
        ])
        contentView.backgroundColor = .purple
        return contentView
    }()
    lazy var collectionView : UICollectionView = {
        let layout = LinkageFullPageLayout()
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo:  contentView.topAnchor, constant: headerTotalHeight),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: contentScroller.heightAnchor, constant: headerFixedHeight)
        ])
        return collectionView
    }()
    lazy var contentScroller : LinkageScroller = {
        let scroller = LinkageScroller()
        scroller.delegate = self
        scroller.bounces = false
        scroller.showsVerticalScrollIndicator = false
        scroller.showsHorizontalScrollIndicator = false
        scroller.backgroundColor = .blue
        scroller.translatesAutoresizingMaskIntoConstraints = false
       
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
        collectionView.reloadData()
    }
    
    
    func setupModels(models:[LinkageModelProtocol], selected index:Int) {
        _models = models
//        let selectindex = max(0, min(index, _models.count - 1))
        for (index, _) in pageModels.enumerated() {
            collectionView.register(PageViewControllerCell.self, forCellWithReuseIdentifier: "cell_\(index)")
        }
        collectionView.reloadData()
    }

}
extension LinkageViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _models.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pageModel = _models[indexPath.row]
        let cell:PageViewControllerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_\(indexPath.row)", for: indexPath) as! PageViewControllerCell
        
        let equal = cell.viewController?.isEqual(pageModel.viewController) ?? false
        if !equal {
            if let tempVc = cell.viewController as? UIViewController  {
                tempVc.view.removeFromSuperview()
                tempVc.removeFromParent()
            }
            cell.viewController = pageModel.viewController
            if let tempVc = cell.viewController as? UIViewController  {
                addChild(tempVc)
                cell.addSubview(tempVc.view)
                tempVc.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    tempVc.view.topAnchor.constraint(equalTo: cell.topAnchor),
                    tempVc.view.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
                    tempVc.view.leftAnchor.constraint(equalTo: cell.leftAnchor),
                    tempVc.view.rightAnchor.constraint(equalTo: cell.rightAnchor)
                ])
            }
        }
        
        pageModel.viewController?.linkpageDelgate = linkpageManger
        if let inner = pageModel.viewController?.scroller {
            linkpageManger.inner = inner
            linkpageManger.outer = contentScroller
        } else {
            linkpageManger.inner = nil
            linkpageManger.outer = contentScroller
        }
        
        return cell
    }
}

extension LinkageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(contentScroller) {
            linkpageManger.scrollViewDidScroll(scroller: scrollView)
            pageModels.forEach { model in
                model.viewController?.outerScrollViewDidScroll?(scroller: scrollView)
            }
        } else if scrollView.isEqual(contentView) {
            view.endEditing(true)
        }
    }
}
