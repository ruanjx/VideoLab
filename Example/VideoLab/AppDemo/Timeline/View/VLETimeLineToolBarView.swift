//
//  VLETimeLineToolBarView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/8/30.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

protocol VLETimeLineToolBarViewDelegate: NSObjectProtocol {
    func toolBarView(_ view: VLETimeLineToolBarView, clickCatButton button: UIButton)
}

class VLETimeLineToolBarView: UIView {
    
    weak var delegate: VLETimeLineToolBarViewDelegate?
    lazy var redoButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "timeline_redo_button"), for: UIControl.State.normal)
        return button
    }()
    
    lazy var undoButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "timeline_undo_button"), for: UIControl.State.normal)
        return button
    }()
    
    lazy var clipButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "timeline_clip_button"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(clickClipButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    init(delegate: VLETimeLineToolBarViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        self.addSubview(undoButton)
        undoButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.centerY.equalToSuperview()
            make.left.equalTo(self.snp_leftMargin).offset(12)
        }
        undoButton.isHidden = true
        self.addSubview(redoButton)
        redoButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.centerY.equalToSuperview()
            make.left.equalTo(undoButton.snp_rightMargin).offset(12)
        }
        redoButton.isHidden = true
        self.addSubview(clipButton)
        clipButton.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.center.equalToSuperview()
        }
        clipButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshClipButtonState(isShow: Bool) {
        clipButton.isHidden = !isShow
    }

    @objc func clickClipButtonAction(sender: UIButton) {
        self.delegate?.toolBarView(self, clickCatButton: clipButton)
    }
}
