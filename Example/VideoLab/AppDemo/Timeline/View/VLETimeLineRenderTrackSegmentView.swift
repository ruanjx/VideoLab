//
//  VLETimeLineRenderTrackSegmentView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/16.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit
import VideoLab
import AVFoundation
import Metal
import MetalKit

class VLETimeLineRenderTrackSegmentView: UIView {

    var thumbnailImageViewArray: [UIImageView] = []
    let model: VLETimeLineItemModel

    init(with model: VLETimeLineItemModel) {
        self.model = model
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshThumbnailImageView(count: Int) {
        if thumbnailImageViewArray.isEmpty {
            var idx = count
            while idx > 0 {
                let imageView = UIImageView.init()
                imageView.contentMode = UIView.ContentMode.scaleAspectFill
                imageView.isUserInteractionEnabled = false
                imageView.clipsToBounds = true
                thumbnailImageViewArray.append(imageView)
                self.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.width.height.equalTo(self.snp.height)
                    make.centerY.equalToSuperview()
                    make.left.equalTo(self.snp.left).offset(64 * CGFloat((count - idx)))
                }
                idx -= 1
            }

            self.model.generateThumbnails(with: count) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        if self.model.source is PHAssetImageSource {
                            for imageView in self.thumbnailImageViewArray {
                                let image = self.model.thumbnailImageArray.first
                                imageView.image = image
                            }
                        } else {
                            var index = 0
                            for imageView in self.thumbnailImageViewArray {
                                let image = self.model.thumbnailImageArray[index]
                                imageView.image = image
                                index += 1
                            }
                        }
                    }
                }
            }
        } else {
            for item in thumbnailImageViewArray {
                item.removeFromSuperview()
            }
            thumbnailImageViewArray.removeAll()
        }
    }
}
