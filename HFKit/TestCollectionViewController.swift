//
//  TestCollectionViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/21.
//

import UIKit

class TestLayout :UICollectionViewFlowLayout {
    override init() {
        super.init()
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup() {
        scrollDirection = .vertical
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        sectionInset = .zero
        itemSize = CGSize.init(width: 300, height: 30)
    }
}

class TestCollectionViewController: UIViewController,LinkageChildViewControllerProtocol,UICollectionViewDelegate {
    weak var linkpageDelgate: LinkageManager?
    var scroller: UIScrollView? {
        get {
           return listViewManager.collectionView
        }
    }
    
    var listViewManager = CollectionViewManager()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        listViewManager.setupListView(superView: self.view, layout: TestLayout())
        listViewManager.delegate = self
           let array = Array(0...100)
        let section = ListViewManagerSection.sectionFor(data: array, cellClass: TestCollectionViewCell.self) {[weak self] cell, cellModel in
               print(cellModel.data ?? "1")
            
            let player = VideoPlayerViewController()
            self?.navigationController?.pushViewController(player, animated: true)
           }
        listViewManager.setupDatas(datas: [section])
       
        // Do any additional setup after loading the view.
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.linkpageDelgate?.scrollViewDidScroll(scroller: scrollView)
    }
}
//
//extension TestCollectionViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize.init(width: 90, height: 40)
//    }
//}
