//
//  Logger.swift
//  HFKit
//
//  Created by helfy on 2021/12/30.
//

import Foundation
import UIKit

struct LoggerManagerFiltter {
    var types:Set<LoggerCellModel.LogType> = []
    var tags:Set<String> = []     // 过滤的tag
    var key:String?       // 需要的过滤内容
}


class LoggerWindow: UIWindow {
    
    var fullScreen:Bool = false {
        didSet {
            let height = fullScreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.height / 2.0
            self.frame.size.height = height
        }
    }
    var loggerViewController = LoggerRootViewController()
    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        self.setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    func setup() {
        
        self.backgroundColor = .black.withAlphaComponent(0.5)
        self.windowLevel = .alert
        self.rootViewController = UINavigationController(rootViewController: loggerViewController)
    }
    
}

open class LoggerManager: NSObject, UITableViewDelegate {
 
    public static let manager = LoggerManager()
    open var loggerAllTags:Set<String> = []    // 使用日志系统中，所有的tags， 
    
    var loggerDatas:[LoggerCellModel] = []   // 日志原始记录
    let semaphore: DispatchSemaphore = DispatchSemaphore.init(value: 1)
    var fillter:LoggerManagerFiltter = LoggerManagerFiltter() {
        didSet {
            filtterDidChanged()
        }
    }
    lazy var window:LoggerWindow = {
        
        var window:LoggerWindow?
        if #available(iOS 13.0, *) {
            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                if windowScene.activationState == .foregroundActive {
                    window = LoggerWindow(windowScene: windowScene)
                  
                }
            }
        }
        if window == nil {
            window = LoggerWindow(frame: UIScreen.main.bounds)
        }
        
        window?.fullScreen = false
    
        return window!
    }()
//    var maxCount: Int = 1000  // 最大条数

    func setFillterKey(key:String?) {
        fillter.key = key
    }
    
    // 输出日志
    open func log(message:String, type:LoggerCellModel.LogType = .normal, tag: String? = nil) {
        semaphore.wait()
        DispatchQueue.hf.async {
            let cellModel = LoggerCellModel(cellClass: LoggerTableViewCell.self)
            cellModel.logInfo = message
            cellModel.logType = type
            cellModel.tag = tag
            if let tag = tag {
                self.loggerAllTags.insert(tag)
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSSSSS"
            let timeStr = formatter.string(from: Date())
            cellModel.systemInfo = timeStr + " --> "
            self.loggerDatas.append(cellModel)
            self.showDataHandle(cellModel: cellModel)
            self.semaphore.signal()
        }
       
    }
    
    func filtterDidChanged() {
        
        DispatchQueue.hf.async {
            let needShowDatas = self.loggerDatas.filter { cellModel in
                self.flitterHandle(cellModel: cellModel)
             }
            DispatchQueue.main.async {
                self.setupShowData(datas: needShowDatas, addMore: false)
            }
        }
    }
    func flitterHandle(cellModel:LoggerCellModel) -> Bool{
        
        var typeTag = true
        // 如果没有 type 表示全数据 不过滤type
        if self.fillter.types.count > 0 {
            typeTag = self.fillter.types.contains(cellModel.logType)
        }
        // type 被过滤掉的情况，就不用判断后续了
        if !typeTag {
            return false
        }
        
        
        var flitterTag = true
        // 如果没有 tags 表示全数据 不过滤tag
        if let tag = cellModel.tag, self.fillter.tags.count > 0 {
            flitterTag = self.fillter.tags.contains(tag)
        }
        // tag 被过滤掉的情况，就不用判断key了
        if !flitterTag {
            return false
        }
        
        
        let message = cellModel.logInfo
        // 判断是否需要过滤字符串
        if let key = self.fillter.key, key.count > 0{
            let hasKey =  message.contains(key)
            return hasKey
        }
        return true
    }
    
    @objc func delayScrollToBottom() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let sections = self.window.loggerViewController.tableManager.sectionModels
        let section = sections.count - 1
        let row = (sections.last?.cellModels.count ?? 0) - 1
        if section >= 0, row > 0 {
            let tableView = self.window.loggerViewController.tableManager.tableView
            if tableView.window != nil {
                tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: false)
            }
        }
    }
    func showDataHandle(cellModel:LoggerCellModel, addMore:Bool? = true) {
//        DispatchQueue.hf.async {
            let canShow = self.flitterHandle(cellModel: cellModel)
            if canShow {
                DispatchQueue.main.async {
                    let tableView = self.window.loggerViewController.tableManager.tableView
                    let scrollerDidBottom = tableView.scrollerDidToBottom()
                    self.window.loggerViewController.tableManager.setupSectionDatas(datas: [cellModel], addMore: true)
                    if scrollerDidBottom {  // 这样可以把短时间内l日志的更新滚动到一起
                        self.perform(#selector(self.delayScrollToBottom), with: nil, afterDelay: 0.01)
                    }
                }
            }
//        }
    }
    func setupShowData(datas:[LoggerCellModel], addMore:Bool = true) {
//        tableManager.setupDatas(datas: datas)
        let tableView = self.window.loggerViewController.tableManager.tableView
        let scrollerDidBottom = tableView.scrollerDidToBottom()
        self.window.loggerViewController.tableManager.setupSectionDatas(datas: datas, addMore: addMore)
        if scrollerDidBottom {
            tableView.scrollToBottom()
        }
    }
}

extension LoggerManager {
    open func show() {
        window.makeKeyAndVisible()
    }
    open func hidden() {
        window.isHidden = true
    }
    
    open func fullAction() {
        window.fullScreen = !window.fullScreen
    }
  
    open func clear() {
        loggerDatas = []
        self.window.loggerViewController.tableManager.setupDatas(datas: [], addMore: false)
    }
}

