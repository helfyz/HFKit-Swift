//
//  TestTableViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/21.
//

import UIKit

class TestTableViewCell : TableViewMangerCell {
    override var cellModel:MangerCellModel? {
        didSet {
            if let index = cellModel?.data as? Int {
                textLabel?.text = "\(index)"
            }
           
        }
    }
    override func setupView() {
        
    }
}

class TestTableViewController: UIViewController,LinkageChildViewControllerProtocol, UITableViewDelegate {
    weak var linkpageDelgate: LinkageManger?
    var scroller: UIScrollView? {
        get {
           return tableManger.tableView
        }
    }
    var tableManger = TableViewManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManger.setupListView(superView: self.view)
           tableManger.delegate = self
           let array = Array(0...100)
            let section = MangerSectionModel.sectionFor(data: array, cellClass: TestTableViewCell.self) { cell, cellModel in
               print(cellModel.data ?? "1")
           }
    
           tableManger.setupDatas(datas: [section])
       
        // Do any additional setup after loading the view.
    }
    
    func reload() {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.linkpageDelgate?.scrollViewDidScroll(scroller: scrollView)
    }

}


