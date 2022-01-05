//
//  TestTableViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/21.
//

import UIKit

class TestTableViewCell : TableViewManagerCell {
    override var cellModel:ListViewManagerCellModel? {
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
    weak var linkpageDelgate: LinkageManager?
    var scroller: UIScrollView? {
        get {
           return tableManager.tableView
        }
    }
    var tableManager = TableViewManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager.setupListView(superView: self.view)
           tableManager.delegate = self
           let array = Array(0...100)
            let section = ListViewManagerSection.sectionFor(data: array, cellClass: TestTableViewCell.self) { cell, cellModel in
                let index = cellModel.data as? Int ?? 0
                if index == 0 {
                    LoggerManager.manager.show()
                } else if index == 10 {
                    LoggerManager.manager.hidden()
                }
             
                LoggerManager.manager.log(message: "\(cellModel.data as? Int ?? 0)", type: .normal, tag: "网络")
                LoggerManager.manager.log(message: "\(cellModel.data as? Int ?? 0)", type: .warning, tag: "埋点")
                LoggerManager.manager.log(message: "\(cellModel.data as? Int ?? 0)", type: .error, tag: "页面Log")
             
               print(cellModel.data ?? "1")
           }
    
           tableManager.setupDatas(datas: [section])
       
        // Do any additional setup after loading the view.
        
    }
    
    func reload() {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.linkpageDelgate?.scrollViewDidScroll(scroller: scrollView)
    }

}


