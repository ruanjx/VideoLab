//
//  VLEPickerStickerCell.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

class VLEPickerStickerCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let view = UIImageView.init()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    func pushImage(image: UIImage) {
        imageView.image = image
    }
}

extension VLEPickerStickerCell {
    static var identifier: String {
        return NSStringFromClass(self)+"CellId"
    }

    static func register(_ collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: identifier)
    }
}
