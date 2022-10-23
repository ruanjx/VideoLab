//
//  VLEExportSaveView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/22.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

protocol VLEExportSaveViewDelegate: NSObjectProtocol {
    func exportSaveViewClickSaveButton(_ button: UIButton)
}

class VLEExportSaveView: UIView {
    weak var delegate: VLEExportSaveViewDelegate?
    
    lazy var saveButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "nav_export_button"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(saveButtonClickAction(sender:)), for: UIControl.Event.touchUpInside)
        return button
    }()

    lazy var saveLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.init(hexString: "#FFFFFF", alpha: 0.7)
        label.text = "导出至本地"
        return label
    }()

    init(delegate: VLEExportSaveViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        self.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 60, height: 60))
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.top).offset(10)
        }

        self.addSubview(saveLabel)
        saveLabel.snp.makeConstraints { make in
            make.centerX.equalTo(saveButton)
            make.top.equalTo(saveButton.snp.bottom)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    @objc func saveButtonClickAction(sender: UIButton) {
        self.delegate?.exportSaveViewClickSaveButton(sender)
    }
}
