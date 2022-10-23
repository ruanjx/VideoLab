//
//  VLEPickerAlbumVideoCell.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/13.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

class VLEPickerAlbumSelectedView: UIView {

    lazy var selectIconImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.clear
        imageView.image = UIImage.init(named: "picker_album_selecticon")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#FF504E", alpha: 0.5)
        self.addSubview(selectIconImageView)
        selectIconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 24, height: 24))
            make.top.equalTo(self.snp.top).offset(8)
            make.left.equalTo(self.snp.left).offset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VLEPickerAlbumVideoCell: UICollectionViewCell {
    lazy var thumbnailImage: UIImageView = {
        let imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var durationLabel: UILabel = {
        let label = UILabel.init()
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "00:00"
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        return label
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

        self.contentView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-10)
            make.right.equalTo(self.contentView.snp.right).offset(-10)
        }

        self.contentView.addSubview(selectedView)
        selectedView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pushData(model: VLEPickerAssetModel) {
        self.durationLabel.text = model.duration
        let size: CGSize
        let maxSideLength = bounds.width * 1.2
        if model.whRatio > 1 {
            let width = maxSideLength * model.whRatio
            size = CGSize(width: width, height: maxSideLength)
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

extension VLEPickerAlbumVideoCell {
    static var identifier: String {
        return NSStringFromClass(self)+"CellId"
    }

    static func register(_ collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: identifier)
    }
}
