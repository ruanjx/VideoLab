//
//  ShaderUniformSettings.swift
//  VideoLab
//
//  Created by Bear on 2020/8/2.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import Foundation
import Metal
import simd

public class ShaderUniformSettings {
    private var uniformValues = [String: Any]()
    private var vertexUniforms: [String: UniformInfo]
    private var fragmentUniforms: [String: UniformInfo]
    
    public init(vertexUniforms: [String: UniformInfo], fragmentUniforms: [String: UniformInfo]) {
        self.vertexUniforms = vertexUniforms
        self.fragmentUniforms = fragmentUniforms
    }
    
    public subscript(key: String) -> Any? {
        get {
            return uniformValues[key]
        }
        set(newValue) {
            uniformValues[key] = newValue
        }
    }
    
    public func restoreShaderSettings(renderEncoder: MTLRenderCommandEncoder) {
        for (uniform, value) in uniformValues {
            if let vertexUniformInfo = vertexUniforms[uniform] {
                renderEncoder.setVertexValue(value, uniformInfo: vertexUniformInfo)
            } else if let fragmentUniformInfo = fragmentUniforms[uniform] {
                renderEncoder.setFragmentValue(value, uniformInfo: fragmentUniformInfo)
            }
        }
    }
}

public struct UniformInfo {
    public let locationIndex: Int
    public let dataSize: Int
}

extension MTLRenderCommandEncoder {
    func setVertexValue(_ value: Any, uniformInfo: UniformInfo) {
        switch value {
        case let value as float3x3:
            var value = value
            setVertexBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        case let value as float4x4:
            var value = value
            setVertexBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        default:
            var value = value
            setVertexBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        }
    }

    func setFragmentValue(_ value: Any, uniformInfo: UniformInfo) {
        switch value {
        case let value as float3x3:
            var value = value
            setFragmentBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        case let value as float4x4:
            var value = value
            setFragmentBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        default:
            var value = value
            setFragmentBytes(&value, length: uniformInfo.dataSize, index: uniformInfo.locationIndex)
        }
    }
}
