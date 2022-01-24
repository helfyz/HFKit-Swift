//
//  LinkageModel.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//

import UIKit
protocol LinkageModelProtocol {
    var title: String? {get set}
    var viewController: LinkageChildViewControllerProtocol? {get set}
}

class LinkageModel: NSObject,LinkageModelProtocol {
    var title: String?
    var viewController: LinkageChildViewControllerProtocol?
    var isCurrent: Bool = false
    convenience init(title:String?, viewController:LinkageChildViewControllerProtocol?) {
        self.init()
        self.title = title
        self.viewController = viewController
    }
}
