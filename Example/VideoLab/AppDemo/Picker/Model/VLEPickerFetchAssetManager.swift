//
//  VLEPickerFetchAssetManager.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/14.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import Photos

class VLEPickerFetchAssetManager: NSObject {

    class func fetchAlbums() -> VLEPickerAlbumListModel {
        var model: VLEPickerAlbumListModel?
        let option = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        smartAlbums.enumerateObjects { collection, _, stop in
            if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                let result = PHAsset.fetchAssets(in: collection, options: option)
                let albumModel = VLEPickerAlbumListModel.init(title: collection.localizedTitle ?? "所有照片", result: result, collection: collection, option: option, isCameraRoll: true)
                model = albumModel
                stop.pointee = true
            }
        }
        return model!
    }

    class func fetchPhoto(in result: PHFetchResult<PHAsset>) -> [VLEPickerAssetModel] {
        var models: [VLEPickerAssetModel] = []
        result.enumerateObjects { asset, _, _ in
            models.append(VLEPickerAssetModel(asset: asset))
        }
        return models
    }
}
