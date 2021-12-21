//
//  LinkageTitleView.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//

import UIKit
protocol LinkageTitleViewDelegate:NSObjectProtocol {
    func linkageTitleView(view:LinkageTitleViewProtocol, indexDidChanged index:Int)
}

protocol LinkageTitleViewProtocol  {

    var delegate:LinkageTitleViewDelegate? { get set }
    var height: CGFloat {get set}
    
    func reload()
    
}

class LinkageTitleView: UIView, LinkageTitleViewProtocol {

    weak var delegate: LinkageTitleViewDelegate?
    var height: CGFloat = 40
    func reload() {
        
    }
}
