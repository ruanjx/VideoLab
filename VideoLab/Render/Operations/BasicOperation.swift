//
//  BasicOperation.swift
//  VideoLab
//
//  Created by Bear on 2020/8/21.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import CoreMedia
import Metal

public func defaultVertexFunctionNameForInputs(_ inputCount:UInt) -> String {
    switch inputCount {
    case 0:
        return "passthroughVertex"
    case 1:
        return "oneInputVertex"
    case 2:
        return "twoInputVertex"
    default:
        return "passthroughVertex"
    }
}

open class BasicOperation: Animatable {
    public let maximumInputs: UInt
    public var uniformSettings: ShaderUniformSettings
    public var enableOutputTextureRead = true
    public var shouldInputSourceTexture = false
    public var timeRange: CMTimeRange?
    let renderPipelineState: MTLRenderPipelineState
    let operationName: String
    var inputTextures = [UInt: Texture]()
    let textureInputSemaphore = DispatchSemaphore(value:1)
    
    public init(vertexFunctionName: String? = nil, fragmentFunctionName: String, numberOfInputs: UInt = 1, operationName: String = #file) {
        self.maximumInputs = numberOfInputs
        self.operationName = operationName
        
        let concreteVertexFunctionName = vertexFunctionName ?? defaultVertexFunctionNameForInputs(numberOfInputs)
        
        let (pipelineState, vertexUniforms, fragmentUniforms) = generateRenderPipelineState(vertexFunctionName:concreteVertexFunctionName,
                                                                       fragmentFunctionName:fragmentFunctionName,
                                                                       operationName:operationName)
        self.renderPipelineState = pipelineState
        self.uniformSettings = ShaderUniformSettings(vertexUniforms: vertexUniforms, fragmentUniforms: fragmentUniforms)
    }
    
    public func addTexture(_ texture: Texture, at index: UInt) {
        inputTextures[index] = texture
    }
    
    public func renderTexture(_ outputTexture: Texture) {
        let _ = textureInputSemaphore.wait(timeout:DispatchTime.distantFuture)
        defer {
            textureInputSemaphore.signal()
        }
        
        if inputTextures.count >= maximumInputs {
            guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else {
                return
            }
            
            commandBuffer.renderQuad(pipelineState: renderPipelineState,
                                     uniformSettings: uniformSettings,
                                     inputTextures: inputTextures,
                                     outputTexture: outputTexture,
                                     enableOutputTextureRead: enableOutputTextureRead)
            commandBuffer.commit()
        }
    }
    
    // MARK: - Animatable
    public var animations: [KeyframeAnimation]?
    public func updateAnimationValues(at time: CMTime) {}
}
