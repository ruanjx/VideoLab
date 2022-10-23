//
//  VLEExportConfigResolutionView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/22.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

class VLEExportConfigResolutionView: UIView{
    let models: [String] = ["360p", "480p", "720p", "1080p", "4K"]
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.text = "分辨率（暂不可用）"
        label.textColor = UIColor.init(hexString: "#FFFFFF")
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel.init()
        label.text = "高清、质量和大小的绝对平衡"
        label.textColor = UIColor.init(hexString: "#FFFFFF", alpha: 0.7)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var sliderView: UISlider = {
        let slider = UISlider.init()
        slider.minimumTrackTintColor = UIColor.init(hexString: "#EB5D57")
        slider.maximumTrackTintColor = UIColor.init(hexString: "#D8D8D8")
        slider.thumbTintColor = UIColor.init(hexString: "#D8D8D8")
        slider.minimumValue = 0
        slider.maximumValue = 4
        slider.value = 2
        slider.addTarget(self, action: #selector(sliderValueDidChangedAction(slider:)), for: UIControl.Event.valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchUpInsideAction(slider:)), for: UIControl.Event.touchUpInside)
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(17)
            make.top.equalToSuperview()
        }
        self.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(17)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        self.addSubview(sliderView)
        sliderView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(18)
            make.right.equalTo(self.snp.right).offset(-18)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(33)
        }
        var index: CGFloat = 0
        let space = (UIScreen.main.bounds.width - 18 * 2 - 35 * CGFloat(models.count)) / (CGFloat(models.count) - 1)
        for item in models {
            let label = UILabel.init()
            label.text = item
            label.textColor = UIColor.init(hexString: "#FFFFFF", alpha: 0.6)
            label.font = UIFont.systemFont(ofSize: 17)
            label.textAlignment = .center
            self.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.equalTo(sliderView.snp.bottom).offset(15)
                make.left.equalTo(sliderView.snp.left).offset(index*(space + 35))
            }
            index += 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    @objc func sliderTouchUpInsideAction(slider: UISlider) {
        var value: Float = 0
        if slider.value.truncatingRemainder(dividingBy: 1) > 0.5 {
            value = Float(Int(slider.value)) + 1
        } else {
            value = Float(Int(slider.value))
        }
        slider.setValue(value, animated: true)
        refreshTitleLabelText(value: value)
    }

    @objc func sliderValueDidChangedAction(slider: UISlider) {
        refreshTitleLabelText(value: slider.value)
    }

    func refreshTitleLabelText(value: Float) {
        switch value {
        case 0:
            subTitleLabel.text = "速度快、占用空间小，质量较差"
        case 0..<1:
            subTitleLabel.text = "速度快、占用空间小，质量较差"
        case 1..<2:
            subTitleLabel.text = "标准。非常适合于在社交媒体上分享。"
        case 2..<3:
            subTitleLabel.text = "高清。质量和大小的绝对平衡。"
        case 3..<4:
            subTitleLabel.text = "全高清。适用于更大的屏幕。"
        case 4:
            subTitleLabel.text = "超高清。就像去看电影一样！"
        default:
            subTitleLabel.text = ""
        }
    }
}
