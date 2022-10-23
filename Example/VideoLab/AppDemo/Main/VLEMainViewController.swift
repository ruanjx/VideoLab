//
//  VLEMainViewController.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/6/6.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit
import SnapKit

class VLEMainViewController: UIViewController {
    
    let playbackViewController: VLEPlaybackViewController
    let timelineViewController: VLETimeLineViewController
    let effectViewController: VLEEffectViewController
    let navViewController: VLENavViewController

    init() {
        self.playbackViewController = VLEPlaybackViewController.init()
        self.timelineViewController = VLETimeLineViewController.init()
        self.effectViewController = VLEEffectViewController.init()
        self.navViewController = VLENavViewController.init()
        super.init(nibName: nil, bundle: nil)
        VLEMainConcreteMediator.shared.mainViewController = self
        VLEMainConcreteMediator.shared.playbackViewController = self.playbackViewController
        VLEMainConcreteMediator.shared.timelineViewController = self.timelineViewController
        VLEMainConcreteMediator.shared.effectViewController = self.effectViewController
        VLEMainConcreteMediator.shared.navViewController = self.navViewController
    }
    
    deinit {
        print("111")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.navViewController.view.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.top).offset(self.view.safeAreaInsets.top)
            make.height.equalTo(48)
            make.width.left.equalToSuperview()
        }
        self.effectViewController.view.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(52 + self.view.safeAreaInsets.bottom)
            make.width.left.equalToSuperview()
        }
        self.timelineViewController.view.snp.makeConstraints { make in
            make.height.equalTo(250)
            make.width.left.equalToSuperview()
            make.bottom.equalTo(self.effectViewController.view.snp.top)
        }
        self.playbackViewController.view.snp.makeConstraints { make in
            make.width.left.equalToSuperview()
            make.top.equalTo(self.navViewController.view.snp.bottom)
            make.bottom.equalTo(self.timelineViewController.view.snp.top)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = UIColor.init(hexString: "#141414")
        self.addChild(self.navViewController)
        self.view.addSubview(self.navViewController.view)
        self.addChild(self.playbackViewController)
        self.view.addSubview(self.playbackViewController.view)
        self.addChild(self.timelineViewController)
        self.view.addSubview(self.timelineViewController.view)
        self.addChild(self.effectViewController)
        self.view.addSubview(self.effectViewController.view)
    }
}
