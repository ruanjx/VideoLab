//
//  VLEEffectItemModel.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/9.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation

enum VLEEffectFirstLevelItemType {
    case canvas
    case text
    case sticker
    case audio
    case filter
    case specialeffect
}

class VLEEffectItemModel {
    
    static let kIconKey = "icon"
    static let kIconType = "type"
    static let kIconTitleKey = "iconTitle"

    let firstLevelItemArray = [[kIconKey: "effect_level1_canvas", kIconTitleKey: "画布", kIconType: VLEEffectFirstLevelItemType.canvas],
                               [kIconKey: "effect_level1_text", kIconTitleKey: "文本", kIconType: VLEEffectFirstLevelItemType.text],
                               [kIconKey: "effect_level1_sticker", kIconTitleKey: "贴纸", kIconType:  VLEEffectFirstLevelItemType.sticker],
                               [kIconKey: "effect_level1_audio", kIconTitleKey: "音频", kIconType: VLEEffectFirstLevelItemType.audio],
                               [kIconKey: "effect_level1_filter", kIconTitleKey: "滤镜", kIconType:VLEEffectFirstLevelItemType.filter],
                               [kIconKey: "effect_level1_specialeffect", kIconTitleKey: "特效", kIconType: VLEEffectFirstLevelItemType.specialeffect]]
}
