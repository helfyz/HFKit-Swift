//
//  LinkageTitleView.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//

import UIKit
protocol LinkageTitleViewDelegate:NSObjectProtocol {
    func linkageTitleView(view:LinkageTitleViewProtocol, indexDidChanged index:Int)
}

protocol LinkageTitleViewProtocol  {

    var delegate:LinkageTitleViewDelegate? { get set }
    var height: CGFloat {get set}
    
    func setupData(models:[LinkageModelProtocol], select index:Int)
    func reload()
}
/**
 默认实现，比较简单，大部分需要根据自己的需求定制一个titleView
 */
class LinkageTitleLayout :UICollectionViewFlowLayout {
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
        sectionInset = .zero
        itemSize = CGSize.init(width: 40, height: 40)
    }
}
class LinkageTitleCell: CollectionViewMangerCell {
  
    var label = UILabel()
    
    override func setupView() {
        self.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    override var cellModel:MangerCellModel? {
        didSet {
            if let pageModel = cellModel?.data as? LinkageModel {
                label.text = pageModel.title
            }
           
        }
    }
}
class LinkageTitleView: UIView, LinkageTitleViewProtocol {

    weak var delegate: LinkageTitleViewDelegate?
    var height: CGFloat = 40
    var listViewManger = CollectionViewManger()
    private var pageModels:[LinkageModelProtocol] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    func setupView() {
        listViewManger.setupListView(superView: self, layout: LinkageTitleLayout())
        listViewManger.delegate = self
        listViewManger.collectionView.backgroundColor = .yellow
    }
    
    func setupData(models:[LinkageModelProtocol], select index:Int) {
        
        let section = MangerSectionModel.sectionFor(data: models, cellClass: LinkageTitleCell.self) { cell, cellModel in
            
            
        }
        for cellModel in section.cellModls {
            cellModel.cellConfig = { cell , cellModel in
                if let cell = cell as? UICollectionViewCell {
                    cell.backgroundColor = .red
                }
           }
        }
        listViewManger.setupDatas(datas: [section])
  
    }
    
    func reload() {
        listViewManger.collectionView.reloadData()
     }
}
extension LinkageTitleView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 90, height: 40)
    }
}
