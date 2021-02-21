//
//  LayerCompositor.swift
//  VideoLab
//
//  Created by Bear on 2020/8/15.
//  Copyright (c) 2020 Chocolate. All rights reserved.
//

import AVFoundation

class LayerCompositor {
    let passthrough = Passthrough()
    let yuvToRGBConversion = YUVToRGBConversion()
    let blendOperation = BlendOperation()

    // MARK: - Public
    func renderPixelBuffer(_ pixelBuffer: CVPixelBuffer, for request: AVAsynchronousVideoCompositionRequest) {
        guard let instruction = request.videoCompositionInstruction as? VideoCompositionInstruction else {
            return
        }
        guard let outputTexture = Texture.makeTexture(pixelBuffer: pixelBuffer) else {
            return
        }
        guard instruction.videoRenderLayers.count > 0 else {
            Texture.clearTexture(outputTexture)
            return
        }

        for (index, videoRenderLayer) in instruction.videoRenderLayers.enumerated() {
            autoreleasepool {
                // The first output must be disabled for reading, because newPixelBuffer is taken from the buffer pool, it may be the previous pixelBuffer
                let enableOutputTextureRead = (index != 0)
                renderLayer(videoRenderLayer, outputTexture: outputTexture, enableOutputTextureRead: enableOutputTextureRead, for: request)
            }
        }
    }
    
    // MARK: - Private
    private func renderLayer(_ videoRenderLayer: VideoRenderLayer,
                     outputTexture: Texture?,
                     enableOutputTextureRead: Bool,
                     for request: AVAsynchronousVideoCompositionRequest) {
        guard let outputTexture = outputTexture else {
            return
        }

        // Convert composite time to internal layer time
        let layerInternalTime = request.compositionTime - videoRenderLayer.timeRangeInTimeline.start
        
        // Update keyframe animation values
        videoRenderLayer.renderLayer.updateAnimationValues(at: layerInternalTime)
        
        // Texture layer: layer source contains video track, layer source is image, layer group
        // The steps to render the texture layer
        // Step 1: Handle its own operations
        // Step 2: Blend with the previous output texture. The previous output texture is a read back renderbuffer
        func renderTextureLayer(_ sourceTexture: Texture) {
            for operation in videoRenderLayer.renderLayer.operations {
                autoreleasepool {
                    if operation.shouldInputSourceTexture, let clonedSourceTexture = cloneTexture(from: sourceTexture) {
                        operation.addTexture(clonedSourceTexture, at: 0)
                        operation.renderTexture(sourceTexture)
                        clonedSourceTexture.unlock()
                    } else {
                        operation.renderTexture(sourceTexture)
                    }
                }
            }
            
            blendOutputText(outputTexture,
                            with: sourceTexture,
                            blendMode: videoRenderLayer.renderLayer.blendMode,
                            blendOpacity: videoRenderLayer.renderLayer.blendOpacity,
                            transform: videoRenderLayer.renderLayer.transform,
                            enableOutputTextureRead: enableOutputTextureRead)
        }
        
        if let videoRenderLayerGroup = videoRenderLayer as? VideoRenderLayerGroup {
            // Layer group
            let textureWidth = outputTexture.width
            let textureHeight = outputTexture.height
            guard let groupTexture = sharedMetalRenderingDevice.textureCache.requestTexture(width: textureWidth, height: textureHeight) else {
                return
            }
            groupTexture.lock()
            
            // Filter layers that intersect with the composite time. Iterate through intersecting layers to render each layer
            let intersectingVideoRenderLayers = videoRenderLayerGroup.videoRenderLayers.filter { $0.timeRangeInTimeline.containsTime(request.compositionTime) }
            for (index, subVideoRenderLayer) in intersectingVideoRenderLayers.enumerated() {
                autoreleasepool {
                    // The first output must be disabled for reading, because groupTexture is taken from the texture cache, it may be the previous texture
                    let enableOutputTextureRead = (index != 0)
                    renderLayer(subVideoRenderLayer, outputTexture: groupTexture, enableOutputTextureRead: enableOutputTextureRead, for: request)
                }
            }
            
            renderTextureLayer(groupTexture)
            groupTexture.unlock()
        } else if videoRenderLayer.trackID != kCMPersistentTrackID_Invalid {
            // Texture layer source contains a video track
            guard let pixelBuffer = request.sourceFrame(byTrackID: videoRenderLayer.trackID) else {
                return
            }
            
            guard let videoTexture = bgraVideoTexture(from: pixelBuffer,
                                                      preferredTransform: videoRenderLayer.preferredTransform) else {
                return
            }
            
            renderTextureLayer(videoTexture)
            if videoTexture.textureRetainCount > 0 {
                // Lock is invoked in the bgraVideoTexture method
                videoTexture.unlock()
            }
        } else if let sourceTexture = videoRenderLayer.renderLayer.source?.texture(at: layerInternalTime) {
            // Texture layer source is a image
            guard let imageTexture = cloneTexture(from: sourceTexture) else {
                return
            }
            
            renderTextureLayer(imageTexture)
            // Lock is invoked in the imageTexture method
            imageTexture.unlock()
        } else {
            // Layer without texture. All operations of the layer are applied to the previous output texture
            for operation in videoRenderLayer.renderLayer.operations {
                autoreleasepool {
                    if operation.shouldInputSourceTexture, let clonedOutputTexture = cloneTexture(from: outputTexture) {
                        operation.addTexture(clonedOutputTexture, at: 0)
                        operation.renderTexture(outputTexture)
                        clonedOutputTexture.unlock()
                    } else {
                        operation.renderTexture(outputTexture)
                    }
                }
            }
        }
    }

    private func bgraVideoTexture(from pixelBuffer: CVPixelBuffer, preferredTransform: CGAffineTransform) -> Texture? {
        var videoTexture: Texture?
        let bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
        let bufferHeight = CVPixelBufferGetHeight(pixelBuffer)

        let pixelFormatType = CVPixelBufferGetPixelFormatType(pixelBuffer);
        if pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange || pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange {
            let luminanceTexture = Texture.makeTexture(pixelBuffer: pixelBuffer, pixelFormat: .r8Unorm, width:bufferWidth, height: bufferHeight, plane: 0)
            let chrominanceTexture = Texture.makeTexture(pixelBuffer: pixelBuffer, pixelFormat: .rg8Unorm, width: bufferWidth / 2, height: bufferHeight / 2, plane: 1)
            if let luminanceTexture = luminanceTexture, let chrominanceTexture = chrominanceTexture {
                let videoTextureSize = CGSize(width: bufferWidth, height: bufferHeight).applying(preferredTransform)
                let videoTextureWidth = abs(Int(videoTextureSize.width))
                let videoTextureHeight = abs(Int(videoTextureSize.height))
                videoTexture = sharedMetalRenderingDevice.textureCache.requestTexture(width: videoTextureWidth, height: videoTextureHeight)
                if let videoTexture = videoTexture {
                    videoTexture.lock()
                    
                    let colorConversionMatrix = pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ? YUVToRGBConversion.colorConversionMatrixVideoRange : YUVToRGBConversion.colorConversionMatrixFullRange
                    yuvToRGBConversion.colorConversionMatrix = colorConversionMatrix
                    let orientationMatrix = preferredTransform.normalizeOrientationMatrix()
                    yuvToRGBConversion.orientation = orientationMatrix
                    yuvToRGBConversion.addTexture(luminanceTexture, at: 0)
                    yuvToRGBConversion.addTexture(chrominanceTexture, at: 1)
                    yuvToRGBConversion.renderTexture(videoTexture)
                }
            }
        } else {
            videoTexture = Texture.makeTexture(pixelBuffer: pixelBuffer)
        }
        return videoTexture
    }
    
    private func cloneTexture(from sourceTexture: Texture) -> Texture? {
        let textureWidth = sourceTexture.width
        let textureHeight = sourceTexture.height
    
        guard let cloneTexture = sharedMetalRenderingDevice.textureCache.requestTexture(width: textureWidth, height: textureHeight) else {
            return nil
        }
        cloneTexture.lock()
        
        passthrough.addTexture(sourceTexture, at: 0)
        passthrough.renderTexture(cloneTexture)
        return cloneTexture
    }
    
    private func blendOutputText(_ outputTexture: Texture,
                                 with texture: Texture,
                                 blendMode: BlendMode,
                                 blendOpacity: Float,
                                 transform: Transform,
                                 enableOutputTextureRead: Bool) {
        // Generate model, view, projection matrix
        let renderSize = CGSize(width: outputTexture.width, height: outputTexture.height)
        let textureSize = CGSize(width: texture.width, height: texture.height)
        let modelViewMatrix = transform.modelViewMatrix(textureSize: textureSize, renderSize: renderSize)
        let projectionMatrix = transform.projectionMatrix(renderSize: renderSize)
        
        // Update blend parameters
        blendOperation.modelView = modelViewMatrix
        blendOperation.projection = projectionMatrix
        blendOperation.blendMode = blendMode
        blendOperation.blendOpacity = blendOpacity
        
        // Render
        blendOperation.enableOutputTextureRead = enableOutputTextureRead
        blendOperation.addTexture(texture, at: 0)
        blendOperation.renderTexture(outputTexture)
    }
}

