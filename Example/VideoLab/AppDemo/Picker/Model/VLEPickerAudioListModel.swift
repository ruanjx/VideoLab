//
//  VLEPickerAudioListModel.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import AVFoundation

class VLEPickerAudioItemModel {
    var url: URL
    var title: String
    var asset: AVAsset
    
    init(title: String, url: URL) {
        self.url = url
        self.title = title
        self.asset = AVAsset.init(url: self.url)
    }
}

class VLEPickerAudioListModel {

    var itemModelArray: [VLEPickerAudioItemModel] = []

    init() {
        for index in (1...16).reversed() {
            let name = "effect_audio_" + String(index)
            let url = Bundle.main.url(forResource: name, withExtension: "m4a")
            let itemModel = VLEPickerAudioItemModel.init(title: name, url: url!)
            itemModelArray.append(itemModel)
        }
    }
}
