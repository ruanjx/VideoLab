//
//  VLEPickerAlbumPhotoCell.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/13.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

class VLEPickerAlbumPhotoCell: UICollectionViewCell{
    lazy var thumbnailImage: UIImageView = {
        let imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()

    lazy var selectedView: VLEPickerAlbumSelectedView = {
        let selectedView = VLEPickerAlbumSelectedView.init()
        return selectedView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        self.contentView.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }

        self.contentView.addSubview(selectedView)
        selectedView.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pushData(model: VLEPickerAssetModel) {
        var size: CGSize
        let maxSideLength = bounds.width * 1.2
        if model.whRatio > 1 {
            let weight = maxSideLength * model.whRatio
            size = CGSize(width: weight, height: maxSideLength)
        } else {
            let height = maxSideLength / model.whRatio
            size = CGSize(width: maxSideLength, height: height)
        }
        model.getAssetThumbnail(size: size) { [weak self] image in
            self?.thumbnailImage.image = image
        }
        self.refreshSelectState(model.isSelected)
    }

    func refreshSelectState(_ isSelected: Bool) {
        if isSelected == true {
            self.selectedView.isHidden = false
        } else {
            self.selectedView.isHidden = true
        }
    }
}

extension VLEPickerAlbumPhotoCell {
    static var identifier: String {
        return NSStringFromClass(self)+"CellId"
    }
    
    static func register(_ collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: identifier)
    }
}
