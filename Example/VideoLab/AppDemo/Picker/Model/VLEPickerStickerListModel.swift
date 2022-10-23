//
//  VLEPickerStickerListModel.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

class VLEPickerStickerListModel {
    var stickerArray: [UIImage] = []
    init() {
        for index in (1...18) {
            let name = "effect_sticker_" + String(index)
            let image = UIImage.init(named: name)
            stickerArray.append(image!)
        }
    }
}
