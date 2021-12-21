//
//  HFTableViewManger.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/8.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit

class TableViewManger:NSObject {
    struct delegateFlags {
        var didScroll:Bool = false
        var didSelectRow:Bool = false
    }
    
    var tableView = UITableView()
    var sectionModel:[TableMangerSectionModel] = []
    
    fileprivate var flags:delegateFlags = delegateFlags()
    
    weak var delegate:UITableViewDelegate? {
        didSet {
            flags.didScroll = delegate?.responds(to: #selector(scrollViewDidScroll(_:))) ?? false
            flags.didSelectRow = delegate?.responds(to: #selector(tableView(_:didSelectRowAt:))) ?? false
            tableView.delegate = self
        }
    }
    weak var dataSource:UITableViewDataSource? {
        didSet {
            tableView.dataSource = self
        }
    }
   
    func setupTabView(view:UIView) {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    func setupDatas(datas:[TableMangerSectionModel], addMore:Bool = false) {
        if addMore {
            sectionModel += datas
        } else {
            sectionModel = datas
        }
        registCellCalss()
        tableView.reloadData()
    }
    func registCellCalss() {
        let fileManger = FileManager.default
        sectionModel.forEach { sectionModel in
            sectionModel.cellModls.forEach { cellModel in
                if let cellNib = cellModel.cellNib {
                    tableView.register(cellNib, forCellReuseIdentifier: cellModel.identifier)
                } else {
                    let path = Bundle.main.path(forResource: cellModel.cellClassName, ofType: "nib")
                    if let path = path, fileManger.fileExists(atPath: path) {
                        let nib = UINib(nibName: cellModel.cellClassName, bundle: nil)
                        tableView.register(nib, forCellReuseIdentifier: cellModel.identifier)
                    } else {
                        tableView.register(NSClassFromString(cellModel.cellClassName), forCellReuseIdentifier: cellModel.identifier)
                    }
                }
            }
        }
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if ((delegate?.responds(to: aSelector)) != nil) {
            return delegate
        } else if ((dataSource?.responds(to: aSelector)) != nil) {
            return dataSource
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
    override func responds(to aSelector: Selector!) -> Bool {
        var res = super.responds(to: aSelector)
        if !res {
            res = (self.delegate?.responds(to: aSelector) ?? false) || (self.dataSource?.responds(to: aSelector) ?? false)
        }
        return res
    }
}


extension TableViewManger: UITableViewDataSource {
    
    func heigthOfSectionSpce(space: TableMangerSectionModel.Space?) -> CGFloat {
        guard (space != nil) else {
            return CGFloat.leastNormalMagnitude
        }
        if let height = space?.height {
            return CGFloat(height)
        } else if let viewHeight = space?.view?.frame.height{
            return viewHeight
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionModel.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModel[section].cellModls.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sectionModel[indexPath.section].cellModls[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.identifier, for: indexPath)
        if let mangerCell = cell as? TableViewMangerCellProtocol {
            mangerCell.cellModel = model
        }
        model.cellConfig?(cell, model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         heigthOfSectionSpce(space: sectionModel[section].header)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         sectionModel[section].header?.title
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         sectionModel[section].header?.view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        heigthOfSectionSpce(space: sectionModel[section].footer)
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sectionModel[section].header?.title
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        sectionModel[section].header?.view
    }
}
extension TableViewManger: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if flags.didSelectRow {
           self.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        } else {
            let model = sectionModel[indexPath.section].cellModls[indexPath.row]
            if let action = model.action{
                self.delegate?.perform(action)
            } else if let callBack = model.callback, let cell = tableView.cellForRow(at: indexPath) {
                callBack(cell, model)
            }
        }
    }
}
/*
 scrollViewDidScroll 和其他代理不一样，需要单独处理下，这里是通过nofity 来的
*/
extension TableViewManger: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if flags.didScroll {
            self.delegate?.scrollViewDidScroll?(scrollView)
        }
    }
}
