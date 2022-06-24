//
//  LoggerSettingViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/31.
//

import UIKit

class LoggerSettingLayout :UICollectionViewFlowLayout {
    var rowShowCount: Int = 3
    var itemHeight: CGFloat = 40
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
        itemSize = CGSize.init(width: 100, height: itemHeight)
        headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
    }
    
    override func prepare() {
        super.prepare()
        if let collectionView = self.collectionView  {
            reCalculation(rect: collectionView.frame)
        }
    }
    func reCalculation(rect: CGRect) {
        let contentRect = rect.inset(by: self.sectionInset)
        let showWidth = (contentRect.width - CGFloat(rowShowCount - 1) * minimumInteritemSpacing)
        let itemWidth =  showWidth / CGFloat(rowShowCount)
        itemSize = CGSize.init(width: floor(itemWidth), height: itemHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        reCalculation(rect: newBounds)
        return true
    }
}

class LoggerSettingHeaderView : CollectionViewSupplementaryView {

    var label = UILabel()
    override var model:ListViewManagerSupplementary? {
        didSet {
            label.text = model?.title
        }
    }
    override func setupView() {
        label.textColor = .black
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15),
            label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 15),
        ])
    }
}

class LoggerSettingViewController: UIViewController, UICollectionViewDelegate {
    var listViewManager = CollectionViewManager()
    
    let typeSection = ListViewManagerSection()
    let tagsSection = ListViewManagerSection()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "设置"
        listViewManager.setupListView(superView: self.view, layout: LoggerSettingLayout())
        listViewManager.delegate = self
        DispatchQueue.hf.async {
            self.setupDatas()
        }
      
    }
    func setupDatas() {
        for type in LoggerCellModel.LogType.allCases {
            let cellModel = LoggerSettingCellModel.init(cellClass: LoggerSettingCollectionCell.self)
            cellModel.data = type
            cellModel.title = type.name()
            cellModel.isSelect = LoggerManager.manager.fillter.types.contains(type)
            cellModel.callback = {[weak self] _ , model in
                if let cellModel = model as? LoggerSettingCellModel {
                    cellModel.isSelect = !cellModel.isSelect
                    if let type = cellModel.data as? LoggerCellModel.LogType {
                        if cellModel.isSelect {
                            LoggerManager.manager.fillter.types.insert(type)
                            
                        } else {
                            LoggerManager.manager.fillter.types.remove(type)
                        }
                    }
                    self?.listViewManager.reloadData()
                }
            }
            typeSection.cellModels.append(cellModel)
        }
        let allTags = LoggerManager.manager.loggerAllTags
        for tag in allTags {
            let cellModel = LoggerSettingCellModel.init(cellClass: LoggerSettingCollectionCell.self)
            cellModel.data = tag
            cellModel.title = tag
            cellModel.isSelect = LoggerManager.manager.fillter.tags.contains(tag)
            cellModel.callback = {[weak self] _ , model in
                if let cellModel = model as? LoggerSettingCellModel {
                    cellModel.isSelect = !cellModel.isSelect
                    if let tag = cellModel.data as? String {
                        if cellModel.isSelect {
                            LoggerManager.manager.fillter.tags.insert(tag)
                            
                        } else {
                            LoggerManager.manager.fillter.tags.remove(tag)
                        }
                    }
                    self?.listViewManager.reloadData()
                }
            }
            tagsSection.cellModels.append(cellModel)
        }
        
        DispatchQueue.main.async {
            self.typeSection.header = {
                let header = ListViewManagerSupplementary()
                header.height = 50
                header.title = "类型"
                header.viewClass = LoggerSettingHeaderView.self
                return header
            }()
            
            self.tagsSection.header = {
                let header = ListViewManagerSupplementary()
                header.height = 50
                header.title = "自定义标签"
                header.viewClass = LoggerSettingHeaderView.self
                return header
            }()
            
            self.listViewManager.setupDatas(datas: [self.typeSection,self.tagsSection])
        }
    }
  
}
