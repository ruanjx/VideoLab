//
//  VLEPickerNavView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

class VLEPickerNavigatorView: UIView {
    
    lazy var closeButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "picker_nav_close"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(closeButtionClickAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.text = "导入"
        label.textColor = UIColor.init(hexString: "#BABABC")
        return label
    }()
    
    lazy var setButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "picker_nav_set"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(setButtonClickAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    var clickCloseButtonBlock: (() -> Void)?
    var clickSetButtonBlock: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#212123")
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.left.equalTo(self.snp.left).offset(12)
            make.top.equalTo(self.snp.top).offset(8)
        }
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.addSubview(setButton)
        setButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.right.equalTo(self.snp.right).offset(-12)
            make.top.equalTo(self.snp.top).offset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func closeButtionClickAction() {
        self.clickCloseButtonBlock?()
    }

    @objc func setButtonClickAction() {
        self.clickSetButtonBlock?()
    }

}
