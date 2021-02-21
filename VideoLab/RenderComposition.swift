//
//  RenderComposition.swift
//  VideoLab
//
//  Created by Bear on 2020/8/29.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import AVFoundation
import UIKit

public class RenderComposition {
    public var backgroundColor: Color = Color.black {
        didSet {
            Color.clearColor = backgroundColor
        }
    }
    
    public var frameDuration: CMTime = CMTime(value: 1, timescale: 30)
    public var renderSize: CGSize = CGSize(width: 720, height: 1280)
    
    public var layers: [RenderLayer] = []
    public var animationLayer: CALayer?
    
    public init() {}
}
