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
        view.backgroundColor = .white
        tableManager.setupListView(superView: contentView)
        tableManager.tableView.scrollsToTop = false
        tableManager.tableView.allowsSelection = false
        if #available(iOS 15.0, *) {
            tableManager.tableView.sectionHeaderTopPadding = 0;
        }
        tableManager.delegate = self
        textField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    
    @IBAction func scrollToTop(_ sender: Any) {
        if tableManager.tableView.visibleCells.count > 0 {
            tableManager.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
        }
    }
    @IBAction func scrollToBottom(_ sender: Any) {
//        tableManager.tableView.scrollToBottom()
        LoggerManager.manager.delayScrollToBottom()
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
            cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .black.withAlphaComponent(0.6) : .black.withAlphaComponent(0.5)
        }
    }
}

//extension LoggerRootViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("====")
//        print(scrollView.contentOffset)
//    }
//}
