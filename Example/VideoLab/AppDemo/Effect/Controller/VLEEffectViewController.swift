//
//  VLEEffectViewController.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/7/21.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit

class VLEEffectViewController: UIViewController{
    
    let model: VLEEffectItemModel = VLEEffectItemModel.init()
    lazy var firstLevelView: VLEEffectFirstLevelView = {
        let view = VLEEffectFirstLevelView.init(with: model)
        return view
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.init(hexString: "#212123")
        self.view.addSubview(firstLevelView)
        firstLevelView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.top.left.equalToSuperview()
        }
        addObserverFromNotification()
    }
    
    func addObserverFromNotification() {
        let name1 = Notification.Name.init(rawValue: VLEConstants.VLETImeLineShowDragSortViewNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(showDragSortViewAction), name: name1, object: nil)
        let name2 = Notification.Name.init(rawValue: VLEConstants.VLETimeLineRemoveDragSortViewNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(removeDragSortViewAction), name: name2, object: nil)
    }
    
    @objc func showDragSortViewAction() {
        self.view.isHidden = true
    }
    
    @objc func removeDragSortViewAction() {
        self.view.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
