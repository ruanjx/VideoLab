//
//  MetalRendering.swift
//  VideoLab
//
//  Created by Bear on 2020/8/19.
//  Copyright (c) 2020 Chocolate. All rights reserved.
//

import Foundation
import Metal

public let standardImageVertices:[Float] = [-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]
public let standardTextureCoordinates: [Float] = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]

extension MTLCommandBuffer {
    func renderQuad(pipelineState:MTLRenderPipelineState,
                    uniformSettings:ShaderUniformSettings? = nil,
                    inputTextures:[UInt:Texture],
                    imageVertices:[Float] = standardImageVertices,
                    textureCoordinates:[Float] = standardTextureCoordinates,
                    outputTexture:Texture,
                    enableOutputTextureRead:Bool) {
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = outputTexture.texture
        renderPass.colorAttachments[0].clearColor = Color.mtlClearColor
        renderPass.colorAttachments[0].storeAction = .store
        renderPass.colorAttachments[0].loadAction = enableOutputTextureRead ? .load : .clear
        
        guard let renderEncoder = self.makeRenderCommandEncoder(descriptor: renderPass) else {
            fatalError("Could not create render encoder")
        }
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBytes(imageVertices, length: imageVertices.count * MemoryLayout<Float>.size, index: 0)

        for textureIndex in 0..<inputTextures.count {
            let currentTexture = inputTextures[UInt(textureIndex)]!
            renderEncoder.setVertexBytes(textureCoordinates, length: textureCoordinates.count * MemoryLayout<Float>.size, index: 1 + textureIndex)
            renderEncoder.setFragmentTexture(currentTexture.texture, index: textureIndex)
        }
        
        uniformSettings?.restoreShaderSettings(renderEncoder: renderEncoder)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
    
    func clearTexture(_ outputTexture: Texture) {
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = outputTexture.texture
        renderPass.colorAttachments[0].clearColor = Color.mtlClearColor
        renderPass.colorAttachments[0].storeAction = .store
        renderPass.colorAttachments[0].loadAction = .clear
        
        guard let renderEncoder = self.makeRenderCommandEncoder(descriptor: renderPass) else {
            fatalError("Could not create render encoder")
        }
        
        renderEncoder.endEncoding()
    }
}

func generateRenderPipelineState(vertexFunctionName:String,
                                 fragmentFunctionName:String, operationName:String) -> (MTLRenderPipelineState, [String: UniformInfo], [String: UniformInfo]) {
    guard let vertexFunction = sharedMetalRenderingDevice.shaderLibrary.makeFunction(name: vertexFunctionName) else {
        fatalError("\(operationName): could not compile vertex function \(vertexFunctionName)")
    }
    
    guard let fragmentFunction = sharedMetalRenderingDevice.shaderLibrary.makeFunction(name: fragmentFunctionName) else {
        fatalError("\(operationName): could not compile fragment function \(fragmentFunctionName)")
    }
    
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
    descriptor.rasterSampleCount = 1
    descriptor.vertexFunction = vertexFunction
    descriptor.fragmentFunction = fragmentFunction
    
    do {
        var reflection:MTLAutoreleasedRenderPipelineReflection?
        let pipelineState = try sharedMetalRenderingDevice.device.makeRenderPipelineState(descriptor: descriptor, options: [.bufferTypeInfo, .argumentInfo], reflection: &reflection)
        
        var uniformLookupTable:[String:(Int, MTLDataType)] = [:]
        if let fragmentArguments = reflection?.fragmentArguments {
            for fragmentArgument in fragmentArguments where fragmentArgument.type == .buffer {
                if
                    (fragmentArgument.bufferDataType == .struct),
                    let members = fragmentArgument.bufferStructType?.members.enumerated() {
                    for (index, uniform) in members {
                        uniformLookupTable[uniform.name] = (index, uniform.dataType)
                    }
                }
            }
        }
        
        var vertexUniforms: [String: UniformInfo] = [:]
        if let vertexArguments = reflection?.vertexArguments {
            for vertexArgument in vertexArguments where vertexArgument.type == .buffer {
                let uniformInfo = UniformInfo(locationIndex: vertexArgument.index, dataSize: vertexArgument.bufferDataSize)
                vertexUniforms[vertexArgument.name] = uniformInfo
            }
        }
        
        var fragmentUniforms: [String: UniformInfo] = [:]
        if let fragmentArguments = reflection?.fragmentArguments {
            for fragmentArgument in fragmentArguments where fragmentArgument.type == .buffer {
                let uniformInfo = UniformInfo(locationIndex: fragmentArgument.index, dataSize: fragmentArgument.bufferDataSize)
                fragmentUniforms[fragmentArgument.name] = uniformInfo
            }
        }

        return (pipelineState, vertexUniforms, fragmentUniforms)
    } catch {
        fatalError("Could not create render pipeline state for vertex:\(vertexFunctionName), fragment:\(fragmentFunctionName), error:\(error)")
    }
}
