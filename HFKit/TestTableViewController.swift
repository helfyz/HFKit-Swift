//
//  TestTableViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/21.
//

import UIKit

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
           let section = MangerSectionModel.sectionFor(data: array, cellClsName: "UITableViewCell") { cell, cellModel in
               print(cellModel.data ?? "1")
           }
           
           for cellModel in section.cellModls {
               cellModel.cellConfig = { cell , cellModel in
                   if let cell = cell as? UITableViewCell {
                       cell.textLabel?.text = "\(cellModel.data as? Int ?? 0)"
                   }
              }
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


