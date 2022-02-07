//
//  LinkageModel.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//

import UIKit
public protocol LinkageModelProtocol {
    var title: String? {get set}
    var viewController: LinkageChildViewControllerProtocol? {get set}
}

open class LinkageModel: NSObject,LinkageModelProtocol {
    public var title: String?
    public var viewController: LinkageChildViewControllerProtocol?
    var isCurrent: Bool = false
    public convenience init(title:String?, viewController:LinkageChildViewControllerProtocol?) {
        self.init()
        self.title = title
        self.viewController = viewController
    }
}
