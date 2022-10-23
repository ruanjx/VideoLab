//
//  VLEPlaybackViewController.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/7/21.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import VideoLab
import AVFoundation

class VLEPlaybackViewController : UIViewController{
    
    lazy var playbackControlView: VLEPlaybackControlView = {
        let view = VLEPlaybackControlView.init(delegate: self)
        return view
    }()
    
    lazy var playbackView: VLEPlaybackView = {
        let view = VLEPlaybackView.init()
        return view
    }()
    
    lazy var hintLabel: UILabel = {
        let label = UILabel.init()
        label.text = "轻点下面的+添加媒体"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.init(hexString: "#FFFFFF")
        return label
    }()
    
    var player: AVPlayer?
    var playLayer : AVPlayerLayer?
    
    override func viewDidLoad() {
        
        self.view.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom).offset(-20)
        }

        self.view.addSubview(playbackView)
        playbackView.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        })

        self.view.addSubview(playbackControlView)
        playbackControlView.snp.makeConstraints({ make in
            make.height.equalTo(40)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp_bottomMargin)
        })

        playbackView.isHidden = true
        playbackControlView.isHidden = true
        addObserverFromNotification()
    }

    func addObserverFromNotification() {
        let name1 = Notification.Name.init(rawValue: VLEConstants.VLETimeLineAssetDidIsEmptyNotification)
        let name2 = Notification.Name.init(rawValue: VLEConstants.VLETimeLineAssetDidIsNonemptyNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(assetDidIsEmpty), name: name1, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(assetDidIsNonempty), name: name2, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func assetDidIsEmpty() {
        if hintLabel.isHidden == true {
            hintLabel.isHidden = false
            playbackView.isHidden = true
            playbackControlView.isHidden = true
        }
    }
    
    @objc func assetDidIsNonempty() {
        if hintLabel.isHidden == false {
            hintLabel.isHidden = true
            playbackView.isHidden = false
            playbackControlView.isHidden = false
        }
    }

    func previewItem(with rate: Float64) {
        if let duration = self.player?.currentItem?.duration {
            let seekTime = CMTimeMultiplyByFloat64(duration, multiplier: rate)
            self.player?.currentItem?.cancelPendingSeeks()
            self.player?.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
    
    func previewItem(with videoLab: VideoLab) {
        let playerItem = videoLab.makePlayerItem()
        playerItem.seekingWaitsForVideoCompositionRendering = true
        if self.player != nil {
            self.player?.replaceCurrentItem(with: playerItem)
        } else {
            self.player = AVPlayer(playerItem: playerItem)
            let avplayerLayer = AVPlayerLayer.init(player: self.player)
            avplayerLayer.videoGravity = .resizeAspect
            let bounds = playbackView.bounds
            avplayerLayer.frame = bounds
            playbackView.layer.addSublayer(avplayerLayer)
            let time = CMTime.init(seconds: 0.1, preferredTimescale: 600)
            self.player?.addPeriodicTimeObserver(forInterval: time, queue: DispatchQueue.main, using: { [weak self] time in
                guard let self = self else { return }
                self.playbackControlView.timeLabel.text = self.convertSecond(for: time)
                VLEMainConcreteMediator.shared.playbackProgressValueDidChanged(currentTime: time)
            })
        }
        self.player?.seek(to: CMTime.init(seconds: 0, preferredTimescale: 600))
    }

    func playbackItem(with videoLab: VideoLab) {
        self.player?.play()
    }

    func convertSecond(for time: CMTime) -> String {
        let origSecond = Int(CMTimeGetSeconds(time))
        switch origSecond {
        case 0..<60:
            return String(format: "00:%02d", origSecond)
        case 60..<3600:
            let minute = origSecond / 60
            let second = origSecond % 60
            return String(format: "%02d:%02d", minute, second)
        case 3600...:
            let hour = origSecond / 3600
            let minute = (origSecond % 3600) / 60
            let second = origSecond % 60
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        default:
            return ""
        }
    }
}

extension VLEPlaybackViewController: VLEPlaybackControlViewDelegate {
    
    func playbackControlView(_ view: VLEPlaybackControlView, clickPlaybackButton button: UIButton) {
        self.player?.play()
    }
}
