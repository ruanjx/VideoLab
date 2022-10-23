//
//  VLEExportShareView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/22.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit
import SwiftUI

class VLEExportShareIconView: UIView {

    let title: String
    let iconName: String

    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(hexString: "#D8D8D8")
        return label
    }()

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    init(title: String, iconName: String) {
        self.title = title
        self.iconName = iconName
        super.init(frame: CGRect.zero)
        self.titleLabel.text = self.title
        self.iconImageView.image = UIImage.init(named: self.iconName)
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        self.addSubview(self.iconImageView)
        self.iconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 32, height: 32))
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

class VLEExportShareView: UIView {
    var models: [[String: String]] = []

    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.text = "分享"
        label.textColor = UIColor.init(hexString: "#FFFFFF")
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(self.snp.left).offset(17)
        }
        var index: CGFloat = 0
        let space: CGFloat = (UIScreen.main.bounds.width - 18 * 2 - 32 * CGFloat(models.count)) / (CGFloat(models.count)-1)
        for item in models {
            let iconView = VLEExportShareIconView.init(title: item["title"]!, iconName: item["iconName"]!)
            self.addSubview(iconView)
            iconView.snp.makeConstraints { make in
                make.top.equalTo(self.snp.top).offset(40)
                make.left.equalTo(self.snp.left).offset(18 + index * (space + 32))
                make.height.equalTo(55)
                make.width.equalTo(32)
            }
            index += 1
        }
        models.append(["iconName": "export_share_weibo", "title": "微博"])
        models.append(["iconName": "export_share_qqzone", "title": "空间"])
        models.append(["iconName": "export_share_qq", "title": "QQ"])
        models.append(["iconName": "export_share_wechat", "title": "微信"])
        models.append(["iconName": "export_share_pengyouquan", "title": "朋友圈"])
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
}
