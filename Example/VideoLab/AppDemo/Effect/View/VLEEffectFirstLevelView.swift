//
//  VLEEffectFirstLevelView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/9.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

class VLEEffectFirstLevelView: UIView {
    
    let model: VLEEffectItemModel
    var iconViewArray: [VLEEffectIconView] = []

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    init(with model: VLEEffectItemModel) {
        self.model = model
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    func setupView() {
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        var index = 0
        let iconW = 80
        for item in self.model.firstLevelItemArray {
            let iconImage = item[VLEEffectItemModel.kIconKey]!
            let iconTitle = item[VLEEffectItemModel.kIconTitleKey]!
            let iconView = VLEEffectIconView.init(with: iconImage as! String, title: iconTitle as! String)
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(iconViewTapGestureAction(sender:)))
            iconView.addGestureRecognizer(gesture)
            iconViewArray.append(iconView)
            scrollView.addSubview(iconView)
            iconView.snp.makeConstraints { make in
                make.size.equalTo(CGSize.init(width: iconW, height: 52))
                make.left.equalTo(self.scrollView.snp.left).offset(0 + index * iconW)
                make.centerY.equalToSuperview()
            }
            index += 1
        }
        scrollView.contentSize = CGSize.init(width: index * iconW, height: 52)
    }
    
    @objc func iconViewTapGestureAction(sender: UITapGestureRecognizer) {
        let index = iconViewArray.firstIndex(of: sender.view as! VLEEffectIconView)
        let itemModel = self.model.firstLevelItemArray[index!]
        let type = itemModel[VLEEffectItemModel.kIconType] as! VLEEffectFirstLevelItemType
        switch  type {
        case .canvas, .text, .filter, .specialeffect:
            HUD.show(.label("暂未开放"))
            HUD.hide(afterDelay: 0.5)
        case .sticker:
            VLEMainConcreteMediator.shared.addStickerWithPickerViewController()
        case .audio:
            VLEMainConcreteMediator.shared.addAudioWithPickerViewController()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }
}
