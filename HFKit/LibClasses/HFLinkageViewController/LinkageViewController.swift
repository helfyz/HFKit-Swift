//
//  LinkageViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//

import UIKit

@objc protocol LinkageChildViewControllerProtocol: NSObjectProtocol {
    var linkpageDelgate:LinkageManager? {get set}
    var scroller:UIScrollView? {get}
    @objc optional  func scrollViewDidScroll(scroller:UIScrollView)
    // 页面出现 & 消失
    @objc optional func linkageControllerWillAppear(animation:Bool)
    @objc optional func linkageControllerWillDisappear(animation:Bool)
    //linkpageVc的滚动 同步到 vc中，用于外部滚动的时候，内部可能需要对偏移做一些处理
    @objc optional func outerScrollViewDidScroll(scroller:UIScrollView)
    @objc optional func reload()
    
}

class PageViewControllerCell: UICollectionViewCell {
    weak var viewController: LinkageChildViewControllerProtocol?
}
class LinkageCollectionView: UICollectionView { }

class LinkageScroller: UIScrollView,UIGestureRecognizerDelegate {
    
    //设置允许手势与其他手势共存
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
       otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is LinkageCollectionView {
            return false
        }
        return true
   }
}

class LinkageViewController: UIViewController {
    var firstCanScrollerBounds: Bool = false
    var fullScreen : Bool = false // 内容全屏，不做安全区的约束
    var headerFixedHeight: CGFloat = 0 // 顶部区域悬浮高度，默认为titleView的高度
    
    var headerContainerHeight: NSLayoutConstraint?
    var collectionViewHeight: NSLayoutConstraint?
  
    lazy var headerContainerView: UIView = { // 头部容器  头部试图 + titleView
        let headerContainerView = UIView()
        contentView.addSubview(headerContainerView)
        return headerContainerView
    }()
    
   var pageHeaderView : UIView?  // 头部视图
    fileprivate var _models: [LinkageModelProtocol] = []

    var pageModels:[LinkageModelProtocol] {
        get {
            _models
        }
    }
    var curIndex: Int = 0 {
        willSet {
           let model = pageModels[curIndex]
            model.viewController?.linkageControllerWillDisappear?(animation: true)
        }
        didSet {
            let model = pageModels[curIndex]
             model.viewController?.linkageControllerWillAppear?(animation: true)
            titleView.changeIndex(index: curIndex, animation: true)
        }
    }
   
    var linkpageManager: LinkageManager = LinkageManager()
    var pageHeaderHeight: CGFloat = 0
    var headerTotalHeight: CGFloat {
        titleView.itemHeight + pageHeaderHeight
    }
    
    var bottomSpace: CGFloat = 0  // 底部留空
    lazy var contentView : UIView = {
        let contentView = UIView()
        contentScroller.addSubview(contentView)
   
        return contentView
    }()
    lazy var collectionView : UICollectionView = {
        let layout = LinkageFullPageLayout()
        let collectionView = LinkageCollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isDirectionalLockEnabled = true
        contentView.addSubview(collectionView)
    
        return collectionView
    }()
    lazy var contentScroller : LinkageScroller = {
        let scroller = LinkageScroller()
        scroller.delegate = self
        scroller.bounces = false
        scroller.isDirectionalLockEnabled = true
        scroller.showsVerticalScrollIndicator = false
        scroller.showsHorizontalScrollIndicator = false
        scroller.backgroundColor = .blue
        view.addSubview(scroller)
  
        return scroller
    }()
   
    lazy var titleView:LinkageTitleViewProtocol = {
        let titleView = LinkageTitleView()
        titleView.delegate = self
        headerContainerView.addSubview(titleView)
        return titleView
    }() {
        willSet{
            if let titleView = titleView as? UIView {
                titleView.removeConstraints(titleView.constraints)
                titleView.removeFromSuperview()
            }
        }
        didSet {
            if let titleView = titleView as? UIView {
                headerContainerView.addSubview(titleView)
                makeTitleLayoutConstraint()
            }
        }
    }
    deinit {
        for model in pageModels {
            model.viewController?.linkpageDelgate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        makeLayoutConstraint()
        
    }
    
    func setupView() {
      
     
    }
    
    // TODO
    func headerDidChanged() {
        headerContainerView.backgroundColor = .black
        updateContainerHeaderHeight()
    }
    // 设置空，表示去掉
    func setupPageHeader(header:UIView?, heigth:CGFloat) {
        
        if pageHeaderView != nil {
            pageHeaderView?.removeFromSuperview()
            pageHeaderView = nil
        }
        if let header = header {
            pageHeaderView = header
        }
        pageHeaderHeight = heigth
    
        guard let pageHeaderView = pageHeaderView else {
            return
        }
        headerContainerView.addSubview(pageHeaderView)
        pageHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageHeaderView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            pageHeaderView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            pageHeaderView.heightAnchor.constraint(equalToConstant: heigth)
        ])
        headerDidChanged()
    }
    
    func setupModels(models:[LinkageModelProtocol], selected index:Int) {
        _models = models
        let selectindex = max(0, min(index, _models.count - 1))
        for (index, _) in pageModels.enumerated() {
            collectionView.register(PageViewControllerCell.self, forCellWithReuseIdentifier: "cell_\(index)")
        }
        titleView.setupData(models: pageModels, select: selectindex)
        collectionView.reloadData()
    }

}
extension LinkageViewController {
    
    func makeLayoutConstraint() {
        contentScroller.translatesAutoresizingMaskIntoConstraints = false
        if(fullScreen) {
            NSLayoutConstraint.activate([
                contentScroller.topAnchor.constraint(equalTo: view.topAnchor),
                contentScroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                contentScroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentScroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]);
        } else {
            NSLayoutConstraint.activate([
                contentScroller.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                contentScroller.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                contentScroller.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                contentScroller.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            ]);
        }
  
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo:  contentScroller.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentScroller.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentScroller.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentScroller.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: contentScroller.widthAnchor),
        ])
        
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerHeight = headerContainerView.heightAnchor.constraint(equalToConstant: headerTotalHeight)
        headerContainerHeight?.isActive = true
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo:  contentView.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeight = collectionView.heightAnchor.constraint(equalTo: contentScroller.heightAnchor, constant: -(headerFixedHeight + titleView.itemHeight))
        collectionViewHeight?.isActive = true
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        makeTitleLayoutConstraint()
    }
    
    func makeTitleLayoutConstraint() {
        if let titleView = titleView as? UIView {
            titleView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
                titleView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
                titleView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
                titleView.heightAnchor.constraint(equalToConstant: self.titleView.itemHeight)
            ])
        }
     
    }
    
    func updateContainerHeaderHeight() {
        headerContainerHeight?.constant = headerTotalHeight
        collectionViewHeight?.constant = -(headerFixedHeight + titleView.itemHeight)
    }
}


extension LinkageViewController: LinkageTitleViewDelegate {
    func linkageTitleView(view: LinkageTitleViewProtocol, indexDidChanged index: Int) {
        curIndex = index
        collectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
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
        
        pageModel.viewController?.linkpageDelgate = linkpageManager
        if let inner = pageModel.viewController?.scroller {
            linkpageManager.inner = inner
            linkpageManager.outer = contentScroller
        } else {
            linkpageManager.inner = nil
            linkpageManager.outer = contentScroller
        }
        
        return cell
    }
}

extension LinkageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(contentScroller) {
            linkpageManager.scrollViewDidScroll(scroller: scrollView)
            pageModels.forEach { model in
                model.viewController?.outerScrollViewDidScroll?(scroller: scrollView)
            }
        } else if scrollView.isEqual(contentView) {
            view.endEditing(true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isEqual(collectionView) {
            let newIndex:Int = Int(scrollView.contentOffset.x / scrollView.frame.size.width + 0.5)
            if curIndex != newIndex , newIndex >= 0 , newIndex < pageModels.count {
                curIndex = newIndex
            }
        }
    }
}
