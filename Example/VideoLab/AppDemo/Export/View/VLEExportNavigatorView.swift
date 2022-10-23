//
//  VLEExportNavigatorView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/22.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

class VLEExportNavigatorView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.init(hexString: "#BABABA")
        label.text = "导出"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "nav_close_button"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(closeButtonClickAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    var clickCloseButtonBlock: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 30, height: 30))
            make.centerY.equalToSuperview()
            make.left.equalTo(self.snp.left).offset(21)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    @objc func closeButtonClickAction() {
        self.clickCloseButtonBlock?()
    }
}
