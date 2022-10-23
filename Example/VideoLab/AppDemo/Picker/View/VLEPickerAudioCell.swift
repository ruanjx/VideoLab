//
//  VLEPickerAudioCell.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

class VLEPickerAudioCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 19)
        return label
    }()
    
    lazy var durationLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#212123")
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(30)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    func pushModel(model: VLEPickerAudioItemModel) {
        titleLabel.text = model.title
        durationLabel.text = String(model.asset.duration.value)
    }
}

extension VLEPickerAudioCell {
    static var identifier: String {
        return NSStringFromClass(self)+"CellId"
    }
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: identifier)
    }
}
