//
//  VLEPickerAssetModel.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/14.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import Photos
import UIKit

extension VLEPickerAssetModel {
    enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
}

class VLEPickerAssetModel: NSObject{
    
    let ident: String
    let asset: PHAsset
    var type: VLEPickerAssetModel.MediaType = .unknown
    var duration: String = ""
    var isSelected: Bool = false
    
    var whRatio: CGFloat {
        return CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }
    
    public init(asset: PHAsset) {
        self.ident = asset.localIdentifier
        self.asset = asset
        super.init()
        type = transformAssetType(for: asset)
        if type == .video {
            duration = transformDuration(for: asset)
        }
    }
    
    func transformAssetType(for asset: PHAsset) -> VLEPickerAssetModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
                return .gif
            }
            if asset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            return .image
        default:
            return .unknown
        }
    }
    
    public func transformDuration(for asset: PHAsset) -> String {
        let duration = Int(round(asset.duration))
        switch duration {
        case 0..<60:
            return String(format: "00:%02d", duration)
        case 60..<3600:
            let minute = duration / 60
            let second = duration % 60
            return String(format: "%02d:%02d", minute, second)
        case 3600...:
            let hour = duration / 3600
            let minute = (duration % 3600) / 60
            let second = duration % 60
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        default:
            return ""
        }
    }
    
    func getAssetThumbnail(size: CGSize, complete: @escaping (UIImage) -> Void) {
        let option = PHImageRequestOptions.init()
        option.resizeMode = PHImageRequestOptionsResizeMode.fast
        PHImageManager.default().requestImage(for: self.asset, targetSize: size, contentMode: PHImageContentMode.default, options: option) { image, info in
            complete(image!)
        }
    }
}

extension PHAsset {
    func getURL(completion: @escaping ((_ responseURL: URL?) -> Void)) {
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completion(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info:  [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completion(localVideoUrl)
                } else {
                    completion(nil)
                }
            })
        }
    }
}
