//
//  LoggerRootViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/30.
//

import UIKit

class LoggerRootViewController: UIViewController {
    
    var tableManager = TableViewManager()
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableManager.setupListView(superView: contentView)
        tableManager.tableView.backgroundColor = .clear
        if #available(iOS 15.0, *) {
            tableManager.tableView.sectionHeaderTopPadding = 0;
        }
        tableManager.delegate = self
        textField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func fillterSearch() {
        LoggerManager.manager.setFillterKey(key: textField.text)
    }

    @IBAction func fullScreenAction(_ sender: Any) {
        LoggerManager.manager.fullAction()
    }
    @IBAction func hiddenAction(_ sender: Any) {
        LoggerManager.manager.hidden()
    }
    @IBAction func clearLogAction(_ sender: Any) {
        LoggerManager.manager.clear()
    }
    @IBAction func flitterSettinAction(_ sender: Any) {
        let setting = LoggerSettingViewController()
        navigationController?.pushViewController(setting, animated: true)
    }
    @IBAction func textDidChanged(_ sender: Any) {
       // TODO 输入过程进行匹配有点耗性能
    }
    
    
    
    

}
extension LoggerRootViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fillterSearch()
        textField.resignFirstResponder()
        return true
    }
}


extension LoggerRootViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? LoggerTableViewCell {
            cell.backgroundColor = indexPath.row % 2 == 0 ? .black.withAlphaComponent(0.2) : .white.withAlphaComponent(0.2)
        }
    }
}

//extension LoggerRootViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("====")
//        print(scrollView.contentOffset)
//    }
//}
