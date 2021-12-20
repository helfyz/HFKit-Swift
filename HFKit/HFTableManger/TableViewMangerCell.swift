//
//  TableViewMangerCell.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/10.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit
@objc protocol TableViewMangerCellProtocol {
    var cellModel:TableMangerCellModel? { get set}
}


class TableViewMangerCell: UITableViewCell,TableViewMangerCellProtocol {
    
    var cellModel: TableMangerCellModel?
    
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
        
    }

}
