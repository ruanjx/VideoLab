//
//  Transform.swift
//  VideoLab
//
//  Created by Bear on 2020/8/12.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import CoreMedia
import simd

public struct Transform: Animatable {
    public var center: CGPoint
    public var rotation: Float
    public var scale: Float

    public static let identity = Transform(center: CGPoint(x: 0.5, y: 0.5),
                                           rotation: 0,
                                           scale: 1.0)

    public init(center: CGPoint, rotation: Float, scale: Float) {
        self.center = center
        self.rotation = rotation
        self.scale = scale
    }
    
    func modelViewMatrix(textureSize: CGSize, renderSize: CGSize) -> matrix_float4x4 {
        // Vertex coordinates are from -1 to 1, so need to divide by 2
        let scaling = float3(Float(textureSize.width) * scale / 2, Float(textureSize.height) * scale / 2, 1)
        let scalingMatrix = float4x4(scaling: scaling)
        
        let rotationMatrix = float4x4(rotationZ: rotation)
        
        let translation = float3(Float((center.x - 0.5) * renderSize.width), Float((0.5 - center.y) * renderSize.height), 0)
        let translationMatrix = float4x4(translation: translation)
        
        return translationMatrix * rotationMatrix * scalingMatrix
    }
    
    func projectionMatrix(renderSize: CGSize) -> matrix_float4x4 {
        return float4x4(orthoLeft: -Float(renderSize.width / 2),
                        right:Float(renderSize.width / 2),
                        bottom: -Float(renderSize.height) / 2,
                        top: Float(renderSize.height) / 2,
                        near: -1,
                        far: 1)
    }
    
    // MARK: - Animatable
    public var animations: [KeyframeAnimation]?
    public mutating func updateAnimationValues(at time: CMTime) {
        // Center point animation
        if let centerX = KeyframeAnimation.value(for: "center.x", at: time, animations: animations) {
            self.center.x = CGFloat(centerX)
        }
        if let centerY = KeyframeAnimation.value(for: "center.y", at: time, animations: animations) {
            self.center.y = CGFloat(centerY)
        }
        
        // Rotation animation
        if let rotation = KeyframeAnimation.value(for: "rotation", at: time, animations: animations) {
            self.rotation = rotation
        }
        
        // Scale animatio
        if let scale = KeyframeAnimation.value(for: "scale", at: time, animations: animations) {
            self.scale = scale
        }
    }
}

