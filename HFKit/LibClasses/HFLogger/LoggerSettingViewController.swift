//
//  LoggerSettingViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/31.
//

import UIKit

class LoggerSettingLayout :UICollectionViewFlowLayout {
    override init() {
        super.init()
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    func setup() {
        scrollDirection = .vertical
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        sectionInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
//        itemSize = CGSize.init(width: 50, height: 30)
        estimatedItemSize = CGSize.init(width: 50, height: 30)
    }
}
class LoggerSettingViewController: UIViewController, UICollectionViewDelegate {
    var listViewManager = CollectionViewManager()
    
    let typeSection = ListViewManagerSection()
    let tagsSection = ListViewManagerSection()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "设置"
        
        listViewManager.setupListView(superView: self.view, layout: LoggerSettingLayout())
        listViewManager.delegate = self
        setupDatas()
    }
    func setupDatas() {
//        typeSection.header = 
        for type in LoggerCellModel.LogType.allCases {
            let cellModel = LoggerSettingCellModel.init(cellClass: LoggerSettingCollectionCell.self)
            cellModel.data = type
            cellModel.title = type.name()
            typeSection.cellModels.append(cellModel)
        }
        
        let allTags = LoggerManager.manager.loggerAllTags
        for tag in allTags {
            let cellModel = LoggerSettingCellModel.init(cellClass: LoggerSettingCollectionCell.self)
            cellModel.data = tag
            cellModel.title = tag
            tagsSection.cellModels.append(cellModel)
      
        }
        listViewManager.setupDatas(datas: [typeSection,tagsSection])
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
}
