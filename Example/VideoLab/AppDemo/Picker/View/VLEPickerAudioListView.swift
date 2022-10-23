//
//  VLEPickerAudioListView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

class VLEPickerAudioListView: UIView{
    
    let model: VLEPickerAudioListModel
    var selectedAudioBlock: ((VLEPickerAudioItemModel)->Void)?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets.init(top: 3, left: 0, bottom: 3, right: 0)
        let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.clear
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        collection.contentInsetAdjustmentBehavior = .always
        VLEPickerAudioCell.register(collection)
        return collection
    }()
    
    init(model: VLEPickerAudioListModel) {
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

extension VLEPickerAudioListView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.itemModelArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.model.itemModelArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VLEPickerAudioCell.identifier, for: indexPath) as! VLEPickerAudioCell
        cell.pushModel(model: model)
        return cell
    }
}

extension VLEPickerAudioListView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }

}

extension VLEPickerAudioListView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.model.itemModelArray[indexPath.row]
        self.selectedAudioBlock?(model)
    }
}
