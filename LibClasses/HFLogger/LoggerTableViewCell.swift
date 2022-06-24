//
//  LoggerTableViewCell.swift
//  HFKit
//
//  Created by helfy on 2021/12/30.
//

import UIKit
//import YYText
open class LoggerCellModel: ListViewManagerCellModel {
    public enum LogType:Int, CaseIterable{
        case normal = 0
        case error
        case warning
        
        func name() -> String{
            switch self {
            case .normal:
                return "正常"
            case .error:
                return "错误"
            case .warning:
                return "警告"
            }
        }
    }
    
    var logType:LogType = .normal
    var tag: String?
    var systemInfo: String = ""
    var logInfo: String = ""
}


class LoggerTableViewCell: TableViewManagerCell {
    @IBOutlet weak var messageLabel: UILabel!
    override var cellModel:ListViewManagerCellModel? {
        didSet {
            guard let cellModel = cellModel as? LoggerCellModel else {
                return
            }
            switch cellModel.logType {
            case .normal:
                messageLabel?.textColor = .white
                break
            case .error:
                messageLabel?.textColor = .red
                break
            case .warning:
                messageLabel?.textColor = .yellow
                break
            }
            
            messageLabel?.text = cellModel.systemInfo + cellModel.logInfo
        }
    }
  
    override func setupView() {
        self.backgroundColor = .clear
        messageLabel.font = UIFont.systemFont(ofSize: 14)
//        messageLabel.displaysAsynchronously = true
        messageLabel.numberOfLines = 0
        messageLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 10
    }
}
