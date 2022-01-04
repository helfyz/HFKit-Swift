//
//  HFTableViewManager.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/8.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit

class ListViewManager: NSObject {
    struct delegateFlags {
        var didScroll:Bool = false
        var didSelectRow:Bool = false
    }
    var sectionModels:[ListViewManagerSection] = []
    fileprivate var flags:delegateFlags = delegateFlags()
    
    func setupDatas(datas:[ListViewManagerSection], addMore:Bool = false) {
        if addMore {
            sectionModels += datas
        } else {
            sectionModels = datas
        }
        registCellCalss()
        reloadData()
    }
    
    func setupSectionDatas(section:ListViewManagerSection? = nil, datas:[ListViewManagerCellModel], addMore:Bool = false) {
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
//        if addMore {
//            var inserts:[IndexPath] = []
//            let sectionIndex:Int = sectionModels.firstIndex(of: section) ?? 0 - 1
//            let sectionPreLastRow = section.cellModels.count - datas.count
//            if sectionIndex < 0, sectionPreLastRow < 0 {
//                reloadData()
//            } else {
//                for index in sectionPreLastRow ..< section.cellModels.count {
//                    inserts.append(IndexPath(row: index, section: sectionIndex))
//                }
//                insertData(inserts: inserts)
//            }
//        } else {
//            reloadData()
//        }
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

class TableViewManager: ListViewManager {
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
    override func reloadData() {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionModels.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModels[section].cellModels.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sectionModels[indexPath.section].cellModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.identifier, for: indexPath)
        if let ManagerCell = cell as? ListManagerCellProtocol {
            ManagerCell.cellModel = model
        }
        model.cellConfig?(cell, model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        heigthOfSectionSupplementary(supplementary: sectionModels[section].header)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionModels[section].header?.title
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = sectionModels[section].header, let identifier = header.identifier, header.canReusable {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
            if let view =  view as? ListManagerSupplementaryProtocol {
                view.model = header
            }
            return view
        }
        return sectionModels[section].header?.view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        heigthOfSectionSupplementary(supplementary: sectionModels[section].footer)
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sectionModels[section].footer?.title
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if flags.didSelectRow {
           self.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        } else {
            let model = sectionModels[indexPath.section].cellModels[indexPath.row]
            if let action = model.action {
                self.delegate?.perform(action)
            } else if let callBack = model.callback, let cell = tableView.cellForRow(at: indexPath) {
                callBack(cell, model)
            }
        }
    }
}

class CollectionViewManager: ListViewManager {
    static let tempSupplementaryIdentifier = "tempSupplementaryIdentifier"
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

extension CollectionViewManager: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionModels.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionModels[section].cellModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = sectionModels[indexPath.section].cellModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
        if let ManagerCell = cell as? ListManagerCellProtocol {
            ManagerCell.cellModel = model
        }
        model.cellConfig?(cell, model)
       return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if flags.didScroll {
            if let `self` = self as? TableViewManager {
                self.delegate?.scrollViewDidScroll?(scrollView)
            } else  if let `self` = self as? CollectionViewManager {
                self.delegate?.scrollViewDidScroll?(scrollView)
            }
        }
    }
}

