//
//  VLETimeLineLongPressMoveItemView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/21.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class VLETimeLineDragSortMoveItemView: UIView{
    
    let longPressDragDisable: Bool = false
    var index: Int = Int.max
    lazy var backImageView: UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(backImageView)
        backImageView.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.addTarget(self, action: #selector(tapGestureRecognizerAction(tapGesture:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapGestureRecognizerAction(tapGesture: UITapGestureRecognizer) {
    }
}
