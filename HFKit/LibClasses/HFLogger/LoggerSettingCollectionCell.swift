//
//  LoggerSettingCollectionCell.swift
//  HFKit
//
//  Created by helfy on 2022/1/4.
//

import UIKit

class LoggerSettingCellModel: ListViewManagerCellModel {
    var isSelect = false
    var title:String = ""  // 用于显示
}

class LoggerSettingCollectionCell: CollectionViewManagerCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setupView() {
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
    }
    override var cellModel: ListViewManagerCellModel? {
        didSet {
            if let cellModel = cellModel as? LoggerSettingCellModel{
                titleLabel.text = cellModel.title
                
                if cellModel.isSelect {
                    titleLabel.textColor = .gray
                    self.layer.borderColor = UIColor.gray.cgColor
                } else {
                    titleLabel.textColor = .black
                    self.layer.borderColor = UIColor.black.cgColor
                }
            }
        }
    }

}
