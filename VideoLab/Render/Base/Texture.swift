//
//  Texture.swift
//  VideoLab
//
//  Created by Bear on 2020/8/18.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import Foundation
import Metal
import CoreVideo
import MetalKit

public class Texture {
    public let texture: MTLTexture
    public var width: Int {
        get {
            return texture.width
        }
    }
    public var height: Int {
        get {
            return texture.height
        }
    }

    public init(texture: MTLTexture) {
        self.texture = texture
    }
    
    public class func makeTexture(pixelBuffer: CVPixelBuffer,
                                  pixelFormat: MTLPixelFormat = .bgra8Unorm,
                                  width: Int? = nil,
                                  height: Int? = nil,
                                  plane: Int = 0) -> Texture? {
        guard let iosurface = CVPixelBufferGetIOSurface(pixelBuffer)?.takeUnretainedValue() else {
            return nil
        }

        let textureWidth: Int, textureHeight: Int
        if let width = width, let height = height {
            textureWidth = width
            textureHeight = height
        } else {
            textureWidth = CVPixelBufferGetWidth(pixelBuffer)
            textureHeight = CVPixelBufferGetHeight(pixelBuffer)
        }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                  width: textureWidth,
                                                                  height: textureHeight,
                                                                  mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        guard let metalTexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: descriptor,
                                                                               iosurface: iosurface,
                                                                               plane: plane) else {
            return nil
        }

        let texture = Texture(texture: metalTexture)
        return texture
    }
    
    public class func makeTexture(pixelFormat: MTLPixelFormat = .bgra8Unorm,
                                  width: Int,
                                  height: Int) -> Texture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                  width: width,
                                                                  height: height,
                                                                  mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        
        guard let metalTexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: descriptor) else {
            return nil
        }
        
        let texture = Texture(texture: metalTexture)
        return texture
    }
    
    // TODO: Limit texture size to reduce memory
    public class func makeTexture(cgImage: CGImage) -> Texture? {
        let metalTexture: MTLTexture
        let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
        let options = [MTKTextureLoader.Option.SRGB : false,
                       MTKTextureLoader.Option.textureUsage:
                        NSNumber(value: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.renderTarget.rawValue)]
        
        do {
            metalTexture = try textureLoader.newTexture(cgImage: cgImage, options: options)
        } catch  {
            fatalError("Failed loading image texture")
        }
        
        let texture = Texture(texture: metalTexture)
        return texture
    }
    
    public class func makeTexture(cgImage: CGImage, completionHandler: @escaping (Texture?) -> Void) {
        let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
        let options = [MTKTextureLoader.Option.SRGB : false,
                       MTKTextureLoader.Option.textureUsage:
                        NSNumber(value: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue | MTLTextureUsage.renderTarget.rawValue)]
        
        textureLoader.newTexture(cgImage: cgImage, options: options) { (metalTexture, error) in
            guard error == nil else {
                completionHandler(nil)
                return
            }
            
            guard let metalTexture = metalTexture else {
                completionHandler(nil)
                return
            }
            
            let texture = Texture(texture: metalTexture)
            completionHandler(texture)
        }
    }
    
    public class func clearTexture(_ texture: Texture) {
        guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else {
            return
        }
        
        commandBuffer.clearTexture(texture)
        commandBuffer.commit()
    }
    
    // MARK: - TextureCache
    var textureRetainCount = 0
    
    public func lock() {
        textureRetainCount += 1
    }
    
    public func unlock() {
        textureRetainCount -= 1
        if textureRetainCount < 1 {
            if textureRetainCount < 0 {
                fatalError("Tried to overrelease a texture")
            }
            textureRetainCount = 0
            sharedMetalRenderingDevice.textureCache.returnToCache(self)
        }
    }
}

extension Texture {
    @objc func debugQuickLookObject() -> Any? {
        return UIImage(cgImage: texture.toImage()!)
    }
}

extension MTLTexture {
    func bytes() -> UnsafeMutableRawPointer {
        let rowBytes = width * 4
        let bytes = malloc(width * height * 4)
        getBytes(bytes!, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        return bytes!
    }

    public func toImage() -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let rawBitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)

        let size = width * height * 4
        let rowBytes = width * 4
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            return
        }
        
        let provider = CGDataProvider(dataInfo: nil, data: bytes(), size: size, releaseData: releaseMaskImagePixelData)
        let cgImageRef = CGImage(width: width,
                                 height: height,
                                 bitsPerComponent: 8,
                                 bitsPerPixel: 32,
                                 bytesPerRow: rowBytes,
                                 space: colorSpace,
                                 bitmapInfo: bitmapInfo,
                                 provider: provider!,
                                 decode: nil,
                                 shouldInterpolate: true,
                                 intent: CGColorRenderingIntent.defaultIntent)!

        return cgImageRef
    }
}
