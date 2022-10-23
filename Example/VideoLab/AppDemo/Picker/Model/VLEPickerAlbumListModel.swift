//
//  VLEPickerAlbumListModel.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/14.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import Photos

class VLEPickerAlbumListModel: NSObject {
    
    let title: String
    var count: Int {
        return result.count
    }
    let option: PHFetchOptions
    var result: PHFetchResult<PHAsset>
    var models: [VLEPickerAssetModel] = []
    let collection: PHAssetCollection

    public init(
        title: String,
        result: PHFetchResult<PHAsset>,
        collection: PHAssetCollection,
        option: PHFetchOptions,
        isCameraRoll: Bool
    ) {
        self.title = title
        self.result = result
        self.collection = collection
        self.option = option
    }

    func refetchPhotos() {
        let models = VLEPickerFetchAssetManager.fetchPhoto(in: result)
        self.models.removeAll()
        self.models.append(contentsOf: models)
    }

    func refreshResult() {
        result = PHAsset.fetchAssets(in: collection, options: option)
    }
}
