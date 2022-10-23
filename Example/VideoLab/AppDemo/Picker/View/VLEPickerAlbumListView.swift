//
//  VLEPickerAlbumListView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

class VLEPickerAlbumListView: UIView {
    
    var assetModelArray: [VLEPickerAssetModel] = []
    
    lazy var albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets.init(top: 3, left: 0, bottom: 3, right: 0)
        
        let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        collection.contentInsetAdjustmentBehavior = .always
        VLEPickerAlbumPhotoCell.register(collection)
        VLEPickerAlbumVideoCell.register(collection)
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#2B2B2B")
        self.addSubview(albumCollectionView)
        albumCollectionView.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pushModel(model: [VLEPickerAssetModel]) {
        assetModelArray.removeAll()
        assetModelArray.append(contentsOf: model)
    }
    
    func pullAssetDataForSelected() -> [VLEPickerAssetModel] {
        var array: [VLEPickerAssetModel]  = []
        for item in assetModelArray {
            if item.isSelected {
                array.append(item)
            }
        }
        return array
    }

    func reload() {
        self.albumCollectionView.reloadData()
    }
}

extension VLEPickerAlbumListView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let assetModel = self.assetModelArray[indexPath.row]
        if assetModel.type == .video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VLEPickerAlbumVideoCell.identifier, for: indexPath) as! VLEPickerAlbumVideoCell
            cell.pushData(model: assetModel)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VLEPickerAlbumPhotoCell.identifier, for: indexPath) as! VLEPickerAlbumPhotoCell
            cell.pushData(model: assetModel)
            return cell
        }
    }
}

extension VLEPickerAlbumListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var columnCount: CGFloat = 3
        if UIApplication.shared.statusBarOrientation.isLandscape {
            columnCount += 2
        }
        let totalW = collectionView.bounds.width - (columnCount - 1) * 5
        let singleW = totalW / columnCount
        return CGSize(width: singleW, height: singleW)
    }
}

extension VLEPickerAlbumListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let assetModel = self.assetModelArray[indexPath.row]
        assetModel.isSelected = !assetModel.isSelected
        if assetModel.type == .video {
            let cell = collectionView.cellForItem(at: indexPath) as! VLEPickerAlbumVideoCell
            cell.refreshSelectState(assetModel.isSelected)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! VLEPickerAlbumPhotoCell
            cell.refreshSelectState(assetModel.isSelected)
        }
    }
}
