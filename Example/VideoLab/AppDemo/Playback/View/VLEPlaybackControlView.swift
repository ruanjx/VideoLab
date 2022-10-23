//
//  VLEPlayControlView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/8/30.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit
import PKHUD

enum VLEPlaybackState {
    case play
    case pause
    case playback
}

protocol VLEPlaybackControlViewDelegate: NSObjectProtocol {
    func playbackControlView(_ view: VLEPlaybackControlView, clickPlaybackButton button: UIButton)
}

class VLEPlaybackControlView : UIView{
    weak var delegate: VLEPlaybackControlViewDelegate?
    lazy var switchFullScreenButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "playback_fullscreen_button"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(switchFullScreenButtonAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel.init()
        label.text = "00:00"
        label.textColor = UIColor.init(hexString: "#BABABA")
        return label
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "playback_play_button"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(playButtonAction), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    init(delegate: VLEPlaybackControlViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        self.addSubview(timeLabel)
        timeLabel.snp.makeConstraints({ make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.snp_leftMargin).offset(5)
        })
        self.addSubview(playButton)
        playButton.snp.makeConstraints({ make in
            make.size.equalTo(32)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        })
        self.addSubview(switchFullScreenButton)
        switchFullScreenButton.snp.makeConstraints({ make in
            make.size.equalTo(32)
            make.centerY.equalToSuperview()
            make.right.equalTo(self.snp_rightMargin).offset(-12)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func playButtonAction() {
        self.delegate?.playbackControlView(self, clickPlaybackButton: self.playButton)
    }
    
    @objc func switchFullScreenButtonAction() {
        HUD.show(.label("暂未开放"))
        HUD.hide(afterDelay: 0.5)
    }
}
