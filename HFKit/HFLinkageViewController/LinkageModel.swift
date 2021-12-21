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
}
