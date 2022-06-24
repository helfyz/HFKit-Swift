//
//  DiffableListViewManger.swift
//  sxsiosapp
//
//  Created by helfy on 2022/6/23.
//  Copyright © 2022 mshare. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
protocol DiffableDataSourceManager: ListViewManagerDataHandle {
    var snapshot: NSDiffableDataSourceSnapshot<ListViewManagerSection, ListViewManagerCellModel> { get }

    func apply(_ snapshot: NSDiffableDataSourceSnapshot<ListViewManagerSection, ListViewManagerCellModel>, animatingDifferences: Bool)
    
    
    
    func reloadAllItems()
    func reload(selctions:[ListViewManagerSection])
    func reload(items:[ListViewManagerCellModel])
    func addItems(items:[ListViewManagerCellModel], for selction:ListViewManagerSection)
    func addItems(selctions:[ListViewManagerSection])
}

@available(iOS 13.0, *)
extension DiffableDataSourceManager {
    /// 刷新所有的cell
    func reloadAllItems() {
        var snapshot = self.snapshot
        let snapshotSections = snapshot.sectionIdentifiers
        snapshot.reloadSections(snapshotSections)

        apply(snapshot, animatingDifferences: false)
    }
    /// 刷新指定的section  注意： section 必须是被预先加载过
    func reload(selctions:[ListViewManagerSection]) {
        var snapshot = self.snapshot
        let snapshotSections = snapshot.sectionIdentifiers
        var needRelodSection:[ListViewManagerSection] = []
        for section in selctions {
            if snapshotSections.contains(section) {
                needRelodSection.append(section)
                snapshot.appendItems(section.cellModels, toSection: section)
            }
        }
        snapshot.reloadSections(needRelodSection)
        apply(snapshot, animatingDifferences: false)
    }
    /// 刷新指定的cell
    func reload(items:[ListViewManagerCellModel]) {
        var snapshot = self.snapshot
        snapshot.reloadItems(items)
        apply(snapshot, animatingDifferences: false)
    }
    /// 添加cell 到指定的 section
    func addItems(items:[ListViewManagerCellModel], for selction:ListViewManagerSection) {
        var snapshot = self.snapshot
//        var snapshot = diffableDatasource.snapshot()
        if !snapshot.sectionIdentifiers.contains(selction) {
            snapshot.appendSections([selction])
        }
        snapshot.appendItems(items, toSection: selction)
        apply(snapshot, animatingDifferences: false)
    }
    
    /// 添加section
    func addItems(selctions:[ListViewManagerSection]) {
        var snapshot = self.snapshot
        snapshot.appendSections(selctions)
        for sectionModel in selctions {
            snapshot.appendItems(sectionModel.cellModels, toSection: sectionModel)
        }
        apply(snapshot, animatingDifferences: false)
    }
    
}

@available(iOS 13.0, *)
extension DiffableDataSourceManager where Self:ListViewManager {
    
    func diffableSetupDatas(datas:[ListViewManagerSection], addMore:Bool = false) {
        if addMore {
            sectionModels += datas
        } else {
            sectionModels = datas
        }
        registCellCalss()
        if addMore {
            addItems(selctions: datas)
        } else {
            reloadAllItems()
        }
    }
    
    func diffableSetupSectionDatas(section:ListViewManagerSection? = nil, datas:[ListViewManagerCellModel], addMore:Bool = false) {
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
        if addMore {
            addItems(items: datas, for: section)
        } else {
            reloadAllItems()
        }
    }

}

@available(iOS 13.0, *)
class DiffableTableViewManager: TableViewManager, DiffableDataSourceManager {
    
    var diffableDatasource: UITableViewDiffableDataSource<ListViewManagerSection, ListViewManagerCellModel>!
    
    override func reloadData() {
        reloadAllItems()
    }
    
    override func setupListView() {
        tableView.delegate = self
        diffableDatasource = UITableViewDiffableDataSource<ListViewManagerSection, ListViewManagerCellModel>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: itemIdentifier.identifier, for: indexPath)
            if let ManagerCell = cell as? ListManagerCellProtocol {
                ManagerCell.cellModel = itemIdentifier
            }
            itemIdentifier.cellConfig?(cell, itemIdentifier)
            return cell
        }
    }
    
    override func setupDatas(datas:[ListViewManagerSection], addMore:Bool = false) {
        diffableSetupDatas(datas: datas, addMore: addMore)
    }
    
    override func setupSectionDatas(section: ListViewManagerSection? = nil, datas: [ListViewManagerCellModel], addMore: Bool = false) {
        diffableSetupSectionDatas(section: section, datas: datas, addMore: addMore)
    }
    
    
    func apply(_ snapshot: NSDiffableDataSourceSnapshot<ListViewManagerSection, ListViewManagerCellModel>, animatingDifferences: Bool) {
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    var snapshot: NSDiffableDataSourceSnapshot<ListViewManagerSection, ListViewManagerCellModel> {
        get {
            diffableDatasource.snapshot()
        }
    }
    
    /// 刷新所有的cell
    func reloadAllItems() {
        var snapshot = diffableDatasource.snapshot()
        let snapshotSections = snapshot.sectionIdentifiers
        snapshot.deleteSections(snapshotSections)
        
        snapshot.appendSections(self.sectionModels)
        for sectionModel in self.sectionModels {
            snapshot.appendItems(sectionModel.cellModels, toSection: sectionModel)
        }
        diffableDatasource.apply(snapshot, animatingDifferences: false)
    }
}

@available(iOS 13.0, *)
class DiffableCollectionManager: CollectionViewManager, DiffableDataSourceManager {
    var diffableDatasource: UICollectionViewDiffableDataSource<ListViewManagerSection, ListViewManagerCellModel>!
    
    override func reloadData() {
        reloadAllItems()
    }
    
    override func setupDataSoure() {
        collectionView.delegate = self
        
        diffableDatasource = UICollectionViewDiffableDataSource<ListViewManagerSection, ListViewManagerCellModel>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let model = itemIdentifier
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
            if let ManagerCell = cell as? ListManagerCellProtocol {
                ManagerCell.cellModel = model
            }
            model.cellConfig?(cell, model)
           return cell
        })
        diffableDatasource.supplementaryViewProvider = {[weak self] collectionView, kind, indexPath in
            
            guard let `self` = self else {
                return nil
            }
    
            var supplementary:ListViewManagerSupplementary?
            if kind == UICollectionView.elementKindSectionHeader {
                supplementary = self.sectionModels[indexPath.section].header
            } else  if kind == UICollectionView.elementKindSectionFooter {
                supplementary = self.sectionModels[indexPath.section].footer
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
    
    open override func setupDatas(datas:[ListViewManagerSection], addMore:Bool = false) {
        diffableSetupDatas(datas: datas, addMore: addMore)
    }
    
    open override func setupSectionDatas(section: ListViewManagerSection? = nil, datas: [ListViewManagerCellModel], addMore: Bool = false) {
        diffableSetupSectionDatas(section: section, datas: datas, addMore: addMore)
    }
    
    
    func apply(_ snapshot: NSDiffableDataSourceSnapshot<ListViewManagerSection, ListViewManagerCellModel>, animatingDifferences: Bool) {
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    var snapshot: NSDiffableDataSourceSnapshot<ListViewManagerSection, ListViewManagerCellModel> {
        get {
            diffableDatasource.snapshot()
        }
    }
    
    /// 刷新所有的cell
    func reloadAllItems() {
        var snapshot = diffableDatasource.snapshot()
        let snapshotSections = snapshot.sectionIdentifiers
        snapshot.deleteSections(snapshotSections)
        
        snapshot.appendSections(self.sectionModels)
        for sectionModel in self.sectionModels {
            snapshot.appendItems(sectionModel.cellModels, toSection: sectionModel)
        }
        diffableDatasource.apply(snapshot, animatingDifferences: false)
    }
}
