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
        let section = ListViewManagerCellModel.sectionFor(data: array, cellClass: TestCollectionViewCell.self) {_, cellModel in
               print(cellModel.data ?? "1")
           }
        
        // 视频测试
        section.cellModels.first?.data = "视频播放"
        section.cellModels.first?.callback = { [weak self] cell, cellModel in
               
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
