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
    var itemHeight: CGFloat {get set}
    
    func setupData(models:[LinkageModelProtocol], select index:Int)
    func changeIndex(index:Int, animation:Bool)
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
class LinkageTitleCell: CollectionViewManagerCell {
    var label = UILabel()
    override func setupView() {
        self.addSubview(label)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    override var cellModel:ListViewManagerCellModel? {
        didSet {
            if let pageModel = cellModel?.data as? LinkageModel {
                label.text = pageModel.title
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .black : .lightGray
        }
    }

}
class LinkageTitleView: UIView, LinkageTitleViewProtocol {

    weak var delegate: LinkageTitleViewDelegate?
    var itemHeight: CGFloat = 40
    var listViewManager = CollectionViewManager()
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
        listViewManager.setupListView(superView: self, layout: LinkageTitleLayout())
        listViewManager.delegate = self
        listViewManager.collectionView.backgroundColor = .yellow
    }
    func setupData(models:[LinkageModelProtocol], select index:Int) {
        let section = ListViewManagerSection.sectionFor(data: models, cellClass: LinkageTitleCell.self) {[weak self]  cell, cellModel in
            if let cell = cell as? UICollectionViewCell, let index = self?.listViewManager.collectionView.indexPath(for: cell)?.row, let titleView = self   {
                self?.delegate?.linkageTitleView(view: titleView, indexDidChanged: index)
            }
        }
        listViewManager.setupDatas(datas: [section])
        listViewManager.collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    func changeIndex(index: Int, animation: Bool) {
        listViewManager.collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    func reload() {
        listViewManager.collectionView.reloadData()
     }
}
extension LinkageTitleView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 100, height: itemHeight)
    }
}