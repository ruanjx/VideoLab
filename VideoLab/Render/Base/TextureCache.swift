//
//  TextureCache.swift
//  VideoLab
//
//  Created by Bear on 2020/8/12.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import Metal

public class TextureCache {
    var textureCache = [String:[Texture]]()
    
    public func requestTexture(pixelFormat: MTLPixelFormat = .bgra8Unorm, width: Int, height: Int) -> Texture? {
        let hash = hashForTexture(pixelFormat: pixelFormat, width: width, height: height)
        let texture: Texture?
        
        if let textureCount = textureCache[hash]?.count, textureCount > 0 {
            texture = textureCache[hash]!.removeLast()
        } else {
            texture = Texture.makeTexture(pixelFormat: pixelFormat, width: width, height: height)
        }
        
        return texture
    }
    
    public func purgeAllTextures() {
        textureCache.removeAll()
    }
    
    public func returnToCache(_ texture: Texture) {
        let hash = hashForTexture(pixelFormat: texture.texture.pixelFormat, width: texture.width, height: texture.height)
        if textureCache[hash] != nil {
            textureCache[hash]?.append(texture)
        } else {
            textureCache[hash] = [texture]
        }
    }
    
    private func hashForTexture(pixelFormat: MTLPixelFormat = .bgra8Unorm, width: Int, height: Int) -> String {
        return "\(width)x\(height)-\(pixelFormat)"
    }
}
