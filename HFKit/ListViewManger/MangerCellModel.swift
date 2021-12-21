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
    init(cellClassName:String) {
        self.cellClassName = cellClassName
    }
    var data: Any?
    var cellNib: UINib?
    // cell 的类名。
    var cellClassName: String = "UITableViewCell"
    var identifier :String = "identifier"
    
    // action方式处理  
    var action: Selector?
    // 回调方式处理
    var callback: MangerCellCallback?
    // cell显示前的配置操作
    var cellConfig: MangerCellCallback?
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
    public class func sectionFor(data:[Any], cellClsName:String!, callBack: MangerCellCallback? = nil) -> MangerSectionModel {
        let section = MangerSectionModel()
        for value in data {
            let cellModel = MangerCellModel(cellClassName: cellClsName)
            cellModel.data = value
            cellModel.callback = callBack
            section.cellModls.append(cellModel)
        }
        return section
    }
    
}
