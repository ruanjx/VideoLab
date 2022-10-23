//
//  VLEPickerBottomView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/11.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

class VLEPickerBottomView: UIView {
    
    lazy var addButton: UIButton = {
        let button = UIButton.init()
        button.backgroundColor = UIColor.init(hexString: "#FF504E")
        let normalAttributedTitle = NSAttributedString(string: "添加", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#FFFFFF")!, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        button.setAttributedTitle(normalAttributedTitle, for: UIControl.State.normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addButtonClickAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    lazy var preViewButton: UIButton = {
        let button = UIButton.init()
        button.backgroundColor = UIColor.init(hexString: "#212123")
        button.setTitle("预览", for: UIControl.State.normal)
        button.setTitleColor(UIColor.init(hexString: "#FFFFFF"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(preViewButtonClickAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "#212123")
        self.addSubview(preViewButton)
        preViewButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.left.equalTo(self.snp.left).offset(18)
            make.top.equalTo(self.snp.top).offset(10)
        }
        preViewButton.isHidden = true
        self.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.right.equalTo(self.snp.right).offset(-18)
            make.top.equalTo(self.snp.top).offset(10)
        }
    }

    var clickAddButtonBlock: (() -> Void)?
    var clickPreViewButtonBlock: (() -> Void)?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func addButtonClickAction() {
        self.clickAddButtonBlock?()
    }
    
    @objc func preViewButtonClickAction() {
        self.clickPreViewButtonBlock?()
    }
}
