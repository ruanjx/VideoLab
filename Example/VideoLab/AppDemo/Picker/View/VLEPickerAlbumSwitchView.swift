//
//  VLEPickerAlbumSwitchView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

class VLEPickerAlbumSwitchView: UIView {
    lazy var localAlbumButton: UIButton = {
        let button = UIButton.init()
        button.backgroundColor = UIColor.clear
        let normalAttributedTitle = NSAttributedString(string: "最近项目", attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#FF504E")!, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        button.setAttributedTitle(normalAttributedTitle, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(localAlbumButtonClickAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    lazy var onlineMaterialButton: UIButton = {
        let button = UIButton.init()
        button.backgroundColor = UIColor.clear
        let normalAttributedTitle = NSAttributedString(string: "在线素材", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#BABABC")!, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        button.setAttributedTitle(normalAttributedTitle, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(onlineMaterialButtonClickAction), for: UIControl.Event.touchUpInside)
        return button
    }()

    lazy var bottomLineView: UIView = {
        let lineView = UIView.init()
        lineView.backgroundColor = UIColor.init(hexString: "#FF504E")
        return lineView
    }()

    var clickLocalAlbumButtonBlock: (() -> Void)?
    var clickOnlineMaterialButtonBlock: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#212123")
        self.addSubview(localAlbumButton)
        localAlbumButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width/2)
            make.left.equalTo(self.snp.left).offset(0)
        }

        self.addSubview(onlineMaterialButton)
        onlineMaterialButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width/2)
            make.right.equalTo(self.snp.right).offset(0)
        }

        self.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(2)
            make.centerX.equalTo(localAlbumButton)
            make.bottom.equalTo(self.snp.bottom).offset(0)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func localAlbumButtonClickAction() {
        self.clickLocalAlbumButtonBlock?()
    }

    @objc func onlineMaterialButtonClickAction() {
        self.clickOnlineMaterialButtonBlock?()
    }
}
