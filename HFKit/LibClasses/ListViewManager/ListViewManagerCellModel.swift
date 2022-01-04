//
//  TableManagerCellModel.swift
//  sxsiosapp
//
//  Created by helfy on 2021/12/10.
//  Copyright © 2021 mshare. All rights reserved.
//

import UIKit

typealias ManagerCellCallback = (Any, ListViewManagerCellModel) -> ()

class ListViewManagerCellModel: NSObject {
    static let ListCellClass = "HFKit.ListCellClass"
    init(cellClass:AnyClass, identifier:String = ListCellClass) {
        _cellClass = cellClass
        if identifier == ListViewManagerCellModel.ListCellClass {
            _identifier = NSStringFromClass(_cellClass)
        } else {
            _identifier = identifier
        }
    }
    var data: Any?
    
    // cell 的类名。 cellNib 如果cell使用xib，且xib的文件名和类名不同，需要传入cellNib
    private var _cellClass: AnyClass
    var cellClass: AnyClass {
        get {
            return _cellClass
        }
    }
    var cellNib: UINib?
    
    private var _identifier :String
    var identifier :String {
        get {
            return _identifier
        }
    }
    
    // action方式处理  
    var action: Selector?
    // 回调方式处理
    var callback: ManagerCellCallback?
    // cell显示前的配置操作
    var cellConfig: ManagerCellCallback?
    
    
    //  对collectionView 生效
    var itemSize:CGSize = .zero
}
/**
    header & footer
 */
class ListViewManagerSupplementary: NSObject {
    
    var title: String?
    
    var data: Any?
    var height: CFloat = Float.leastNormalMagnitude
    
    /*复用机制  */
    // view 的类名。 viewNib 如果view使用xib，且xib的文件名和类名不同，需要传入viewNib
    var viewClass: AnyClass?
    var viewNib: UINib?
    var identifier: String?
    
    var canReusable: Bool {
        return identifier != nil && (viewClass != nil || viewNib != nil)
    }
    /*不复用机制 适用用于少量且UI相似度不高的头部/底部设置*/
    var view: UIView?
}

class ListViewManagerSection: NSObject {

    var cellModels:[ListViewManagerCellModel] = []
    //对section 的标识。用户获取section。如果不设置，不能通过identifier 获取或者reload该section
    var identifier: String?
    
    var header: ListViewManagerSupplementary?
    var footer: ListViewManagerSupplementary?
    
    // 通过数组，直接创建section
    public class func sectionFor(data:[Any], cellClass:AnyClass!, callBack: ManagerCellCallback? = nil) -> ListViewManagerSection {
        let section = ListViewManagerSection()
        for value in data {
            let cellModel = ListViewManagerCellModel(cellClass: cellClass)
            cellModel.data = value
            cellModel.callback = callBack
            section.cellModels.append(cellModel)
        }
        return section
    }
    
}
