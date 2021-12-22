//
//  TableMangerCellModel.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/10.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit

typealias MangerCellCallback = (Any, MangerCellModel) -> ()

class MangerCellModel: NSObject {
    init(cellClass:AnyClass) {
        self.cellClass = cellClass
    }
    var data: Any?
    
    // cell 的类名。 cellNib 如果cell使用xib，且xib的文件名和类名不同，需要传入cellNib
    var cellClass: AnyClass
    var cellNib: UINib?
    
    var identifier :String = "identifier"
    
    // action方式处理  
    var action: Selector?
    // 回调方式处理
    var callback: MangerCellCallback?
    // cell显示前的配置操作
    var cellConfig: MangerCellCallback?
    
    
    //  对collectionView 生效
    var itemSize:CGSize = .zero
}
/**
    header & footer使用相对比较少，这里暂时没有采用复用机制
 */
class MangerSectionModel: NSObject {
    struct Space {
        var title: String
        var height: CFloat = Float.leastNormalMagnitude
        var view: UIView?
    }
    
    var cellModls:[MangerCellModel] = []
    //对section 的标识。用户获取section。如果不设置，不能通过identifier 获取或者reload该section
    var identifier: String?
    
    var header: Space?
    var footer: Space?
    
    // 通过数组，直接创建section
    public class func sectionFor(data:[Any], cellClass:AnyClass!, callBack: MangerCellCallback? = nil) -> MangerSectionModel {
        let section = MangerSectionModel()
        for value in data {
            let cellModel = MangerCellModel(cellClass: cellClass)
            cellModel.data = value
            cellModel.callback = callBack
            section.cellModls.append(cellModel)
        }
        return section
    }
    
}
