//
//  TestCollectionViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/21.
//

import UIKit

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
        listViewManger.setupListView(superView: self.view)
        listViewManger.delegate = self
           let array = Array(0...100)
           let section = MangerSectionModel.sectionFor(data: array, cellClsName: "UICollectionViewCell") { cell, cellModel in
               print(cellModel.data ?? "1")
           }
           
           for cellModel in section.cellModls {
               cellModel.cellConfig = { cell , cellModel in
                   if let cell = cell as? UICollectionViewCell {
                       cell.backgroundColor = .red
                   }
              }
           }
        listViewManger.setupDatas(datas: [section])
       
        // Do any additional setup after loading the view.
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.linkpageDelgate?.scrollViewDidScroll(scroller: scrollView)
    }
}
