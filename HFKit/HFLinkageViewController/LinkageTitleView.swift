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

protocol LinkageTitleViewProtocol {
    func reload()
    var delegate:LinkageTitleViewDelegate? { get set }
}



class LinkageTitleView: UIView, LinkageTitleViewProtocol {

    weak var delegate: LinkageTitleViewDelegate?
    
    func reload() {
        
    }
}
