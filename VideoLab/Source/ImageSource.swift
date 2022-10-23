//
//  ImageSource.swift
//  VideoLab
//
//  Created by Bear on 2020/8/1.
//

import AVFoundation
import UIKit

public class ImageSource: Source {
    private var cgImage: CGImage?
    var texture: Texture?

    public init(cgImage: CGImage?) {
        self.cgImage = cgImage
        duration = CMTime(seconds: 3, preferredTimescale: 600) // Default duration
        selectedTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
    }
    
    public init() {
        duration = CMTime(seconds: 3, preferredTimescale: 600) // Default duration
        selectedTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
    }
    
    public func copy() -> Source {
        let source = ImageSource.init()
        source.isLoaded = false
        source.cgImage = self.cgImage
        source.texture = self.texture
        source.duration = CMTime(seconds: 3, preferredTimescale: 600) // Default duration
        source.selectedTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
        return source
    }

    // MARK: - Source
    public var selectedTimeRange: CMTimeRange
    
    public var duration: CMTime
    
    public var isLoaded: Bool = false
    
    public func load(completion: @escaping (NSError?) -> Void) {
        guard let cgImage = cgImage else {
            let error = NSError(domain: "com.source.load",
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Image is nil", comment: "")])
            completion(error)
            isLoaded = true
            return
        }
        
        Texture.makeTexture(cgImage: cgImage) { [weak self] (texture) in
            guard let self = self else { return }
            
            self.texture = texture
            self.isLoaded = true
            completion(nil)
        }
    }
    
    public func tracks(for type: AVMediaType) -> [AVAssetTrack] {
        return []
    }
    
    public func texture(at time: CMTime) -> Texture? {
        if isLoaded {
            return texture
        }
        
        defer {
            isLoaded = true
        }
        guard let cgImage = cgImage else {
            return nil
        }
        texture = Texture.makeTexture(cgImage: cgImage)
        return texture
    }
}
