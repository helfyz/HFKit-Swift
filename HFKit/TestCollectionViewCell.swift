//
//  TestCollectionViewCell.swift
//  HFKit
//
//  Created by helfy on 2021/12/22.
//

import UIKit

class TestCollectionViewCell: CollectionViewMangerCell {
    
    
    @IBOutlet weak var label: UILabel!
    override var cellModel:MangerCellModel? {
        didSet {
            if let index = cellModel?.data as? Int {
                label.text = "\(index)"
            }
           
        }
    }
   

}
