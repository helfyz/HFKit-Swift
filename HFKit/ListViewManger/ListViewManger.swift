//
//  HFTableViewManger.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/8.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit
class ListViewManger: NSObject {
    struct delegateFlags {
        var didScroll:Bool = false
        var didSelectRow:Bool = false
    }
    var sectionModels:[MangerSectionModel] = []
    fileprivate var flags:delegateFlags = delegateFlags()
    func setupDatas(datas:[MangerSectionModel], addMore:Bool = false) {
        if addMore {
            sectionModels += datas
        } else {
            sectionModels = datas
        }
        registCellCalss()
    }
    
//    func setupListView(superView view:UIView) {
//        fatalError("Must Override")
//    }
    func registCellCalss() {
        fatalError("Must Override")
    }
}

class TableViewManger: ListViewManger {
    lazy var tableView = {
        UITableView()
    }()
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
   
    func setupListView(superView view:UIView) {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
//        tableView.frame = view.bounds
    }
    
    override func setupDatas(datas:[MangerSectionModel], addMore:Bool = false) {
        super.setupDatas(datas: datas, addMore: addMore)
        tableView.reloadData()
    }
    override func registCellCalss() {
        let fileManger = FileManager.default
        sectionModels.forEach { sectionModel in
            sectionModel.cellModls.forEach { cellModel in
                if let cellNib = cellModel.cellNib {
                    tableView.register(cellNib, forCellReuseIdentifier: cellModel.identifier)
                } else {
                    let cellClassName = NSStringFromClass(cellModel.cellClass).components(separatedBy: ".").last ?? ""
                    let path = Bundle.main.path(forResource: cellClassName, ofType: "nib")
                    if let path = path, fileManger.fileExists(atPath: path) {
                        let nib = UINib(nibName: cellClassName, bundle: nil)
                        tableView.register(nib, forCellReuseIdentifier: cellModel.identifier)
                    } else {
                        tableView.register(cellModel.cellClass, forCellReuseIdentifier: cellModel.identifier)
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
    
    func heigthOfSectionSpce(space: MangerSectionModel.Space?) -> CGFloat {
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
        sectionModels.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModels[section].cellModls.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sectionModels[indexPath.section].cellModls[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.identifier, for: indexPath)
        if let mangerCell = cell as? MangerCellProtocol {
            mangerCell.cellModel = model
        }
        model.cellConfig?(cell, model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         heigthOfSectionSpce(space: sectionModels[section].header)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionModels[section].header?.title
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionModels[section].header?.view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        heigthOfSectionSpce(space: sectionModels[section].footer)
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sectionModels[section].header?.title
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        sectionModels[section].header?.view
    }
}
extension TableViewManger: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if flags.didSelectRow {
           self.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        } else {
            let model = sectionModels[indexPath.section].cellModls[indexPath.row]
            if let action = model.action{
                self.delegate?.perform(action)
            } else if let callBack = model.callback, let cell = tableView.cellForRow(at: indexPath) {
                callBack(cell, model)
            }
        }
    }
}

class CollectionViewManger: ListViewManger {
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    weak var delegate: UICollectionViewDelegate? {
        didSet {
            flags.didScroll = delegate?.responds(to: #selector(scrollViewDidScroll(_:))) ?? false
            flags.didSelectRow = delegate?.responds(to: #selector(collectionView(_:didSelectItemAt:))) ?? false
            collectionView.delegate = self
        }
    }
    weak var dataSource:UICollectionViewDataSource? {
        didSet {
            collectionView.dataSource = self
        }
    }
    func setupListView(superView view:UIView, layout:UICollectionViewLayout? = nil) {
        if let layout = layout {
            collectionView.collectionViewLayout = layout
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    override func setupDatas(datas:[MangerSectionModel], addMore:Bool = false) {
        super.setupDatas(datas: datas, addMore: addMore)
        collectionView.reloadData()
    }
    override func registCellCalss() {
        let fileManger = FileManager.default
        sectionModels.forEach { sectionModel in
            sectionModel.cellModls.forEach { cellModel in
                if let cellNib = cellModel.cellNib {
                    collectionView.register(cellNib, forCellWithReuseIdentifier: cellModel.identifier)
                } else {
                    let cellClassName = NSStringFromClass(cellModel.cellClass).components(separatedBy: ".").last ?? ""
                    let path = Bundle.main.path(forResource: cellClassName, ofType: "nib")
                    if let path = path, fileManger.fileExists(atPath: path) {
                        let nib = UINib(nibName: cellClassName, bundle: nil)
                        collectionView.register(nib, forCellWithReuseIdentifier: cellModel.identifier)
                    } else {
                        collectionView.register(cellModel.cellClass, forCellWithReuseIdentifier: cellModel.identifier)
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

extension CollectionViewManger: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionModels.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionModels[section].cellModls.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = sectionModels[indexPath.section].cellModls[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
        if let mangerCell = cell as? MangerCellProtocol {
            mangerCell.cellModel = model
        }
        model.cellConfig?(cell, model)
       return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if flags.didSelectRow {
            self.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
        } else {
            let model = sectionModels[indexPath.section].cellModls[indexPath.row]
            if let action = model.action {
                self.delegate?.perform(action)
            } else if let callBack = model.callback, let cell = collectionView.cellForItem(at: indexPath) {
                callBack(cell, model)
            }
        }
    }

}

/*
 scrollViewDidScroll 和其他代理不一样，需要单独处理下，这里是通过nofity 来的
*/
extension ListViewManger: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if flags.didScroll {
            if let `self` = self as? TableViewManger {
                self.delegate?.scrollViewDidScroll?(scrollView)
            } else  if let `self` = self as? CollectionViewManger {
                self.delegate?.scrollViewDidScroll?(scrollView)
            }
        }
    }
}

