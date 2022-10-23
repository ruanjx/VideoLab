//
//  VLEEffectIconView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/9.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

class VLEEffectIconView: UIView {

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(hexString: "#D8D8D8")
        return label
    }()

    init(with iconImage: String, title: String) {
        super.init(frame: CGRect.zero)
        iconImageView.image = UIImage.init(named: iconImage)
        titleLabel.text = title
        self.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 32, height: 32))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(0)
            make.centerX.equalToSuperview()
            make.height.equalTo(17)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }
}
