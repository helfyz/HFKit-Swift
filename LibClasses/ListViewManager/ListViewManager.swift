//
//  HFTableViewManager.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/8.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit

protocol ListViewManagerDataHandle {
    var sectionModels:[ListViewManagerSection] { get set }
    
    func registCellCalss()
    func reloadData()
}

open class ListViewManager: NSObject, ListViewManagerDataHandle {
    
    struct delegateFlags {
        var didScroll:Bool = false
        var didSelectRow:Bool = false
    }
    
    var sectionModels:[ListViewManagerSection] = []
    fileprivate var flags:delegateFlags = delegateFlags()
    
    
    open func setupDatas(datas:[ListViewManagerSection], addMore:Bool = false) {
         if addMore {
             sectionModels += datas
         } else {
             sectionModels = datas
         }
         registCellCalss()
         reloadData()
     }
    open func setupSectionDatas(section:ListViewManagerSection? = nil, datas:[ListViewManagerCellModel], addMore:Bool = false) {
         var addMore = addMore
         var section = section
         if section == nil {
             if sectionModels.count > 0 {
                 section = sectionModels.last
             } else {
                 section = ListViewManagerSection()
                 sectionModels.append(section!)
             }
         }
         guard let section = section else {
             return
         }
         
         if(section.cellModels.count == 0) {
             addMore = false
         }
         if addMore {
             section.cellModels += datas
         } else {
             section.cellModels = datas
         }
         registCellCalss()
         reloadData()
     }
    



 
//    func setupListView(superView view:UIView) {
//        fatalError("Must Override")
//    }
    func registCellCalss() {
        fatalError("Must Override")
    }
    func reloadData() {
        fatalError("Must Override")
    }
    func insertData(inserts:[IndexPath]) {
        fatalError("Must Override")
    }
}

open class TableViewManager: ListViewManager {
    open lazy var tableView: UITableView = {
        let tableView = UITableView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    open weak var delegate:UITableViewDelegate? {
        didSet {
            flags.didScroll = delegate?.responds(to: #selector(scrollViewDidScroll(_:))) ?? false
            flags.didSelectRow = delegate?.responds(to: #selector(tableView(_:didSelectRowAt:))) ?? false
            tableView.delegate = self
        }
    }
    open weak var dataSource:UITableViewDataSource? {
        didSet {
            tableView.dataSource = self
        }
    }
   
    open func setupListView(superView view:UIView) {
        setupListView()
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
    
    /// 不需要设置autolayout版本
    open func setupListView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    open override func reloadData() {
        tableView.reloadData()
    }
    
    override func insertData(inserts:[IndexPath]) {
        print(inserts)
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates {
                tableView.insertRows(at: inserts, with: .none)
            } completion: { success in
                
            }
        }else {
            tableView.beginUpdates()
            tableView.insertRows(at: inserts, with: .none)
            tableView.endUpdates()
        }
    }
    
    override func registCellCalss() {
        let fileManager = FileManager.default
        var needRegistModels:[String:ListViewManagerCellModel] = [:]
        var needRegistSupplementarys:[String:ListViewManagerSupplementary] = [:]
     
        // 利用词典的key 唯一性进行class标识去重
        sectionModels.forEach { sectionModel in
            if let supplementaryKey = sectionModel.header?.identifier, (sectionModel.header?.canReusable ?? false) {
                needRegistSupplementarys[supplementaryKey] = sectionModel.header
            }
            if let supplementaryKey = sectionModel.footer?.identifier, (sectionModel.footer?.canReusable ?? false) {
                needRegistSupplementarys[supplementaryKey] = sectionModel.footer
            }
            
            sectionModel.cellModels.forEach { cellModel in
                needRegistModels[cellModel.identifier] = cellModel
            }
        }
        needRegistModels.forEach { (key: String, cellModel: ListViewManagerCellModel) in
                let identifier = cellModel.identifier
                if let cellNib = cellModel.cellNib {
                    tableView.register(cellNib, forCellReuseIdentifier: identifier)
                } else {
                    let cellClassName = NSStringFromClass(cellModel.cellClass).components(separatedBy: ".").last ?? ""
                    let path = Bundle.main.path(forResource: cellClassName, ofType: "nib")
                    if let path = path, fileManager.fileExists(atPath: path) {
                        let nib = UINib(nibName: cellClassName, bundle: nil)
                        tableView.register(nib, forCellReuseIdentifier: identifier)
                    } else {
                        tableView.register(cellModel.cellClass, forCellReuseIdentifier: identifier)
                    }
                }
        }
        needRegistSupplementarys.forEach { (identifier: String, supplementary: ListViewManagerSupplementary) in
            if let viewNib = supplementary.viewNib {
                tableView.register(viewNib, forHeaderFooterViewReuseIdentifier: identifier)
            } else  if let viewClass = supplementary.viewClass  {
                let viewClassName = NSStringFromClass(viewClass).components(separatedBy: ".").last ?? ""
                let path = Bundle.main.path(forResource: viewClassName, ofType: "nib")
                if let path = path, fileManager.fileExists(atPath: path) {
                    let nib = UINib(nibName: viewClassName, bundle: nil)
                    tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
                } else {
                    tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
                }
            }
        }
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if ((delegate?.responds(to: aSelector)) != nil) {
            return delegate
        } else if ((dataSource?.responds(to: aSelector)) != nil) {
            return dataSource
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
    open override func responds(to aSelector: Selector!) -> Bool {
        var res = super.responds(to: aSelector)
        if !res {
            res = (self.delegate?.responds(to: aSelector) ?? false) || (self.dataSource?.responds(to: aSelector) ?? false)
        }
        return res
    }
}


extension TableViewManager: UITableViewDataSource {
    
    func heigthOfSectionSupplementary(supplementary: ListViewManagerSupplementary?) -> CGFloat {
        guard (supplementary != nil) else {
            return CGFloat.leastNormalMagnitude
        }
        if let height = supplementary?.height {
            return CGFloat(height)
        } else if let viewHeight = supplementary?.view?.frame.height{
            return viewHeight
        }
        return CGFloat.leastNormalMagnitude
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        sectionModels.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModels[section].cellModels.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sectionModels[indexPath.section].cellModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.identifier, for: indexPath)
        if let ManagerCell = cell as? ListManagerCellProtocol {
            ManagerCell.cellModel = model
        }
        model.cellConfig?(cell, model)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        heigthOfSectionSupplementary(supplementary: sectionModels[section].header)
    }
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionModels[section].header?.title
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = sectionModels[section].header, let identifier = header.identifier, header.canReusable {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
            if let view =  view as? ListManagerSupplementaryProtocol {
                view.model = header
            }
            return view
        }
        return sectionModels[section].header?.view
    }
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        heigthOfSectionSupplementary(supplementary: sectionModels[section].footer)
    }
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sectionModels[section].footer?.title
    }
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footer = sectionModels[section].footer, let identifier = footer.identifier, footer.canReusable {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
            if let view =  view as? ListManagerSupplementaryProtocol {
                view.model = footer
            }
            return view
        }
        return sectionModels[section].footer?.view
    }
}
extension TableViewManager: UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if flags.didSelectRow {
           self.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        } else {
            let model = sectionModels[indexPath.section].cellModels[indexPath.row]
            if let action = model.action {
                self.delegate?.perform((action), with: model)
            } else if let callBack = model.callback, let cell = tableView.cellForRow(at: indexPath) {
                callBack(cell, model)
            }
        }
    }
}

open class CollectionViewManager: ListViewManager {
    static let tempSupplementaryIdentifier = "tempSupplementaryIdentifier"
    open lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    open weak var delegate: UICollectionViewDelegate? {
        didSet {
            flags.didScroll = delegate?.responds(to: #selector(scrollViewDidScroll(_:))) ?? false
            flags.didSelectRow = delegate?.responds(to: #selector(collectionView(_:didSelectItemAt:))) ?? false
            collectionView.delegate = self
        }
    }
    open weak var dataSource:UICollectionViewDataSource? {
        didSet {
            collectionView.dataSource = self
        }
    }
    open func setupListView(superView view:UIView, layout:UICollectionViewLayout? = nil) {
        if let layout = layout {
            collectionView.collectionViewLayout = layout
        }
        setupDataSoure()
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    open func setupListView(layout:UICollectionViewLayout? = nil) {
        if let layout = layout {
            collectionView.collectionViewLayout = layout
        }
        setupDataSoure()
    }
    open func setupDataSoure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    override func reloadData() {
        collectionView.reloadData()
    }
    override func insertData(inserts:[IndexPath]) {
        collectionView.insertItems(at: inserts)
    }
    override func registCellCalss() {
        let fileManager = FileManager.default
        var needRegistModels:[String:ListViewManagerCellModel] = [:]
//        var headers:[String:ListViewManagerSupplementary] = [:]
        var supplementarys:[String:(String, ListViewManagerSupplementary)] = [:]
     
        // 利用词典的key 唯一性进行class标识去重
        sectionModels.forEach { sectionModel in
            if let supplementary = sectionModel.header,
                let supplementaryKey = supplementary.identifier,
                (sectionModel.header?.canReusable ?? false) {
                supplementarys[supplementaryKey] = (UICollectionView.elementKindSectionHeader, supplementary)
            }
            if let supplementary = sectionModel.footer,
                let supplementaryKey = supplementary.identifier,
                (sectionModel.header?.canReusable ?? false) {
              supplementarys[supplementaryKey] = (UICollectionView.elementKindSectionHeader, supplementary)
            }
            sectionModel.cellModels.forEach { cellModel in
                needRegistModels[cellModel.identifier] = cellModel
            }
        }
        needRegistModels.forEach { (key: String, cellModel: ListViewManagerCellModel) in
            if let cellNib = cellModel.cellNib {
                collectionView.register(cellNib, forCellWithReuseIdentifier: cellModel.identifier)
            } else {
                let cellClassName = NSStringFromClass(cellModel.cellClass).components(separatedBy: ".").last ?? ""
                let path = Bundle.main.path(forResource: cellClassName, ofType: "nib")
                if let path = path, fileManager.fileExists(atPath: path) {
                    let nib = UINib(nibName: cellClassName, bundle: nil)
                    collectionView.register(nib, forCellWithReuseIdentifier: cellModel.identifier)
                } else {
                    collectionView.register(cellModel.cellClass, forCellWithReuseIdentifier: cellModel.identifier)
                }
            }
        }
        supplementarys.forEach { (identifier: String, value: (String, ListViewManagerSupplementary)) in
            let (kind, supplementary) = value
            if let viewNib = supplementary.viewNib {
               collectionView.register(viewNib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
            } else if let viewClass = supplementary.viewClass {
                   let cellClassName = NSStringFromClass(viewClass).components(separatedBy: ".").last ?? ""
                   let path = Bundle.main.path(forResource: cellClassName, ofType: "nib")
                   if let path = path, fileManager.fileExists(atPath: path) {
                       let nib = UINib(nibName: cellClassName, bundle: nil)
                       collectionView.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
                   } else {
                       collectionView.register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
                   }
            }
        }
        collectionView.register(CollectionViewTempSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewManager.tempSupplementaryIdentifier)
        collectionView.register(CollectionViewTempSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionViewManager.tempSupplementaryIdentifier)
   
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if ((delegate?.responds(to: aSelector)) != nil) {
            return delegate
        } else if ((dataSource?.responds(to: aSelector)) != nil) {
            return dataSource
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
    open override func responds(to aSelector: Selector!) -> Bool {
        var res = super.responds(to: aSelector)
        if !res {
            res = (self.delegate?.responds(to: aSelector) ?? false) || (self.dataSource?.responds(to: aSelector) ?? false)
        }
        return res
    }
}

extension CollectionViewManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionModels.count
    }
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionModels[section].cellModels.count
    }
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = sectionModels[indexPath.section].cellModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
        if let ManagerCell = cell as? ListManagerCellProtocol {
            ManagerCell.cellModel = model
        }
        model.cellConfig?(cell, model)
       return cell
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if flags.didSelectRow {
            self.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
        } else {
            let model = sectionModels[indexPath.section].cellModels[indexPath.row]
            if let action = model.action {
                self.delegate?.perform(action)
            } else if let callBack = model.callback, let cell = collectionView.cellForItem(at: indexPath) {
                callBack(cell, model)
            }
        }
    }
 
    //
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var supplementary:ListViewManagerSupplementary?
        if kind == UICollectionView.elementKindSectionHeader {
            supplementary = sectionModels[indexPath.section].header
        } else  if kind == UICollectionView.elementKindSectionFooter {
            supplementary = sectionModels[indexPath.section].footer
        }
        if let supplementary = supplementary, let identifier = supplementary.identifier, supplementary.canReusable {
            let view =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
            if let view =  view as? ListManagerSupplementaryProtocol {
                view.model = supplementary
            }
            return view
        }
        
        let view =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewManager.tempSupplementaryIdentifier, for: indexPath) as! CollectionViewTempSupplementaryView
        view.model = supplementary
        return view
    }
}

/*
 scrollViewDidScroll 和其他代理不一样，需要单独处理下，这里是通过nofity 来的
*/
extension ListViewManager: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if flags.didScroll {
            if let `self` = self as? TableViewManager {
                self.delegate?.scrollViewDidScroll?(scrollView)
            } else  if let `self` = self as? CollectionViewManager {
                self.delegate?.scrollViewDidScroll?(scrollView)
            }
        }
    }
}

