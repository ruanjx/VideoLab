//
//  MathLibrary.swift
//  VideoLab
//
//  Created by Bear on 2020/8/4.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import simd
import CoreGraphics

typealias float2 = SIMD2<Float>
typealias float3 = SIMD3<Float>
typealias float4 = SIMD4<Float>

let π = Float.pi

// MARK:- float4
extension float4x4 {
    // MARK:- Translate
    init(translation: float3) {
        let matrix = float4x4(
            [            1,             0,             0, 0],
            [            0,             1,             0, 0],
            [            0,             0,             1, 0],
            [translation.x, translation.y, translation.z, 1]
        )
        self = matrix
    }
    
    // MARK:- Scale
    init(scaling: float3) {
        let matrix = float4x4(
            [scaling.x,         0,         0, 0],
            [        0, scaling.y,         0, 0],
            [        0,         0, scaling.z, 0],
            [        0,         0,         0, 1]
        )
        self = matrix
    }

    // MARK:- Rotate
    init(rotationX angle: Float) {
        let matrix = float4x4(
            [1,           0,          0, 0],
            [0,  cos(angle), sin(angle), 0],
            [0, -sin(angle), cos(angle), 0],
            [0,           0,          0, 1]
        )
        self = matrix
    }
    
    init(rotationY angle: Float) {
        let matrix = float4x4(
            [cos(angle), 0, -sin(angle), 0],
            [         0, 1,           0, 0],
            [sin(angle), 0,  cos(angle), 0],
            [         0, 0,           0, 1]
        )
        self = matrix
    }
    
    init(rotationZ angle: Float) {
        let matrix = float4x4(
            [ cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
        )
        self = matrix
    }
    
    init(rotation angle: float3) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }
    
    init(rotationYXZ angle: float3) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationY * rotationX * rotationZ
    }
    
    // MARK:- Identity
    static func identity() -> float4x4 {
        matrix_identity_float4x4
    }
    
    // MARK:- Orthographic matrix
    init(orthoLeft left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) {
        let X = float4(2 / (right - left), 0, 0, 0)
        let Y = float4(0, 2 / (top - bottom), 0, 0)
        let Z = float4(0, 0, 1 / (far - near), 0)
        let W = float4((left + right) / (left - right),
                       (top + bottom) / (bottom - top),
                       near / (near - far),
                       1)
        self.init()
        columns = (X, Y, Z, W)
    }
}

extension CGAffineTransform {
    public func orientationMatrix() -> float4x4 {
        var orientation = float4x4.identity()
        orientation[0][0] = Float(a)
        orientation[0][1] = Float(c)
        orientation[1][0] = Float(b)
        orientation[1][1] = Float(d)
        
        return orientation
    }
    
    public func normalizeOrientationMatrix() -> float4x4 {
        let transitionBeforeRotation = float4x4(translation: float3(-0.5, -0.5, 0))
        let orientation = orientationMatrix()
        let transitionAfterRotation = float4x4(translation: float3(0.5, 0.5, 0))
        
        return transitionAfterRotation * orientation * transitionBeforeRotation
    }
}
