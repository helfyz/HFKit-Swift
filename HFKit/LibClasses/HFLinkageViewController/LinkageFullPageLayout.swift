//
//  LinkageFullPageLayout.swift
//  HFKit
//
//  Created by helfy on 2021/12/21.
//

import UIKit

class LinkageFullPageLayout: UICollectionViewFlowLayout {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init() {
        super.init()
        setup()
    }
    
    override func prepare() {
        super.prepare()
        if let collectionView = collectionView {
            itemSize = collectionView.frame.size
        }
    }
    
    func setup() {
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = .zero
        if let collectionView = collectionView {
            itemSize = collectionView.frame.size
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        itemSize = newBounds.size
        return true
    }
    
    override func finalizeLayoutTransition() {
        if let collectionView = collectionView {
            itemSize = collectionView.frame.size
        }
    }
}
