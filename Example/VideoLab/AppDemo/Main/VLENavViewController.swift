//
//  VLENavViewController.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/8/29.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class VLENavViewController: UIViewController{
    
    lazy var setButton: UIButton = makeSetButton()
    lazy var projectlistButton: UIButton = makeProjectListButton()
    lazy var helpButton: UIButton = makeHelpButton()
    lazy var closeButton: UIButton = makeCloseButton()
    lazy var exportButton: UIButton = makeExportButton()
    
    override func viewDidLoad() {
        self.view.addSubview(setButton)
        setButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
        self.view.addSubview(projectlistButton)
        projectlistButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.left.equalTo(setButton.snp_rightMargin).offset(16)
            make.centerY.equalToSuperview()
        }
        self.view.addSubview(helpButton)
        helpButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.left.equalTo(projectlistButton.snp_rightMargin).offset(16)
            make.centerY.equalToSuperview()
        }
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }
        self.view.addSubview(exportButton)
        exportButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.right.equalTo(closeButton.snp.leftMargin).offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    @objc func setButtonAction() {
    }

    @objc func projectlistButtonAction() {
    }

    @objc func helpButtonAction() {
    }

    @objc func exportButtonAction() {
        let controller = VLEExportViewController.init()
        self.present(controller, animated: true)
    }

    @objc func closeButtonAction() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
    }
}

extension VLENavViewController {
    private func makeSetButton() -> UIButton {
        let setButton: UIButton = UIButton.init()
        setButton.addTarget(self, action: #selector(setButtonAction), for: UIControl.Event.touchUpInside)
        setButton.setBackgroundImage(UIImage.init(named: "nav_set_button"), for: UIControl.State.normal)
        return setButton
    }
    
    private func makeProjectListButton() -> UIButton {
        let projectlistButton: UIButton = UIButton.init()
        projectlistButton.addTarget(self, action: #selector(projectlistButtonAction), for: UIControl.Event.touchUpInside)
        projectlistButton.setBackgroundImage(UIImage.init(named: "nav_projectlist_button"), for: UIControl.State.normal)
        return projectlistButton
    }
    
    private func makeHelpButton() -> UIButton {
        let helpButton: UIButton = UIButton.init()
        helpButton.addTarget(self, action: #selector(helpButtonAction), for: UIControl.Event.touchUpInside)
        helpButton.setBackgroundImage(UIImage.init(named: "nav_help_button"), for: UIControl.State.normal)
        return helpButton
    }
    
    private func makeCloseButton() -> UIButton {
        let closeButton: UIButton = UIButton.init()
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: UIControl.Event.touchUpInside)
        closeButton.setBackgroundImage(UIImage.init(named: "nav_close_button"), for: UIControl.State.normal)
        return closeButton
    }
    
    private func makeExportButton() -> UIButton {
        let exportButton: UIButton = UIButton.init()
        exportButton.addTarget(self, action: #selector(exportButtonAction), for: UIControl.Event.touchUpInside)
        exportButton.setBackgroundImage(UIImage.init(named: "nav_export_button"), for: UIControl.State.normal)
        return exportButton
    }
}
