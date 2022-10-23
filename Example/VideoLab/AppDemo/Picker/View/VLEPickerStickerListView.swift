//
//  VLEPickerStickerListView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import VideoLab

class VLEPickerStickerListView: UIView {
    
    let model: VLEPickerStickerListModel
    var selectedStickerBlock: ((UIImage) -> Void)?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets.init(top: 3, left: 0, bottom: 3, right: 0)
        
        let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        collection.contentInsetAdjustmentBehavior = .always
        VLEPickerStickerCell.register(collection)
        return collection
    }()
    
    init(model: VLEPickerStickerListModel) {
        self.model = model
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.init(hexString: "#2B2B2B")
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VLEPickerStickerListView: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.stickerArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let image = self.model.stickerArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VLEPickerStickerCell.identifier, for: indexPath) as! VLEPickerStickerCell
        cell.pushImage(image: image)
        return cell
    }
}

extension VLEPickerStickerListView: UICollectionViewDelegateFlowLayout {
    
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

extension VLEPickerStickerListView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = self.model.stickerArray[indexPath.row]
        self.selectedStickerBlock?(image)
    }
}
