//
//  TableViewManagerCell.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/10.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit
@objc protocol ListManagerCellProtocol {
    var cellModel:ListViewManagerCellModel? { get set}
}

@objc protocol ListManagerSupplementaryProtocol {
    var model:ListViewManagerSupplementary? { get set}
}

open class TableViewManagerCell: UITableViewCell,ListManagerCellProtocol {
    var cellModel: ListViewManagerCellModel?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    func setupView() {
//        fatalError("Must Override")
    }
}

open class CollectionViewManagerCell: UICollectionViewCell,ListManagerCellProtocol {
    open var cellModel: ListViewManagerCellModel?
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    func setupView() {
        
    }
}

/**
 主要针对CollectionView 使用
 **/
class CollectionViewSupplementaryView : UICollectionReusableView, ListManagerSupplementaryProtocol {
    
    var model:ListViewManagerSupplementary?
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    func setupView() {
        
    }
}

class CollectionViewTempSupplementaryView : CollectionViewSupplementaryView {

    override var model:ListViewManagerSupplementary? {
        didSet {
            if let subView = model?.view {
                subView.removeFromSuperview()
                self.addSubview(subView)
                subView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    subView.topAnchor.constraint(equalTo: self.topAnchor),
                    subView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    subView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15),
                    subView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 15),
                ])
            }
        }
    }
    override func setupView() {
        
    }
}
/**
 主要针对TableView 使用
 **/
class TableViewSupplementaryView : UITableViewHeaderFooterView, ListManagerSupplementaryProtocol {
    
    var model:ListViewManagerSupplementary?
    required override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    func setupView() {
        
    }
}
