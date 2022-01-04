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

class TableViewManagerCell: UITableViewCell,ListManagerCellProtocol {
    var cellModel: ListViewManagerCellModel?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        fatalError("Must Override")
    }
}

class CollectionViewManagerCell: UICollectionViewCell,ListManagerCellProtocol {
    var cellModel: ListViewManagerCellModel?
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
    var subView:UIView?
    override var model:ListViewManagerSupplementary? {
        willSet {
            subView?.removeFromSuperview()
        }
        didSet {
            if let subView = model?.view {
                self.subView = subView
                self.addSubview(subView)
                NSLayoutConstraint.activate([
                    subView.topAnchor.constraint(equalTo: self.topAnchor),
                    subView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    subView.leftAnchor.constraint(equalTo: self.leftAnchor),
                    subView.rightAnchor.constraint(equalTo: self.rightAnchor),
                    
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
