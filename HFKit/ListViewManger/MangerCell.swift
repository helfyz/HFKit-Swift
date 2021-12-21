//
//  TableViewMangerCell.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/10.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit
@objc protocol MangerCellProtocol {
    var cellModel:MangerCellModel? { get set}
}


class TableViewMangerCell: UITableViewCell,MangerCellProtocol {
    
    var cellModel: MangerCellModel?
    
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


class CollectionViewMangerCell: UICollectionViewCell,MangerCellProtocol {
    
    var cellModel: MangerCellModel?
    
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
