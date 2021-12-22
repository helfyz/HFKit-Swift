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
    weak var linkpageDelgate: LinkageManger?
    var scroller: UIScrollView? {
        get {
           return listViewManger.collectionView
        }
    }
    
    var listViewManger = CollectionViewManger()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        listViewManger.setupListView(superView: self.view, layout: TestLayout())
        listViewManger.delegate = self
           let array = Array(0...100)
        let section = MangerSectionModel.sectionFor(data: array, cellClass: TestCollectionViewCell.self) { cell, cellModel in
               print(cellModel.data ?? "1")
           }
           
//           for cellModel in section.cellModls {
//               cellModel.cellConfig = { cell , cellModel in
//                   if let cell = cell as? UICollectionViewCell {
//                       cell.backgroundColor = .red
//                   }
//              }
//           }
        listViewManger.setupDatas(datas: [section])
       
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
