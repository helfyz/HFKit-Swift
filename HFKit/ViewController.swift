//
//  ViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//
import UIKit

class ViewController: UIViewController {
    
    var tableManger = TableViewManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
     
        tableManger.setupTabView(view: self.view)
        tableManger.delegate = self
        let array = Array(0...100)
        let section = TableMangerSectionModel.sectionFor(data: array, cellClsName: "UITableViewCell") { cell, cellModel in
            print(cellModel.data ?? "1")
        }
        
        for cellModel in section.cellModls {
            cellModel.cellConfig = { cell, cellModel in
               cell.textLabel?.text = "\(cellModel.data as? Int ?? 0)"
           }
        }
        tableManger.setupDatas(datas: [section])
    }
}
extension ViewController: UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("111")
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("222")
    }
}

