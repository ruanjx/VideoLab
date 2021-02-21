//
//  TextOpacityAnimationLayer.swift
//  VideoLab
//
//  Created by Bear on 2020/8/11.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import AVFoundation

public class TextOpacityAnimationLayer: TextAnimationLayer {
    override func addAnimations(to layers: [CATextLayer]) {
        var beginTime = AVCoreAnimationBeginTimeAtZero
        let beginTimeInterval = 0.125
        
        for layer in layers {
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 15.0
            animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
            animationGroup.fillMode = .both
            animationGroup.isRemovedOnCompletion = false

            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 0.0
            opacityAnimation.toValue = 1.0
            opacityAnimation.duration = 0.125
            opacityAnimation.beginTime = beginTime
            opacityAnimation.fillMode = .both

            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 0.0
            scaleAnimation.toValue = 1.0
            scaleAnimation.duration = 0.125
            scaleAnimation.beginTime = beginTime
            scaleAnimation.fillMode = .both
            
            animationGroup.animations = [opacityAnimation, scaleAnimation]
            layer.add(animationGroup, forKey: "animationGroup")

            beginTime += beginTimeInterval
        }
    }
}
