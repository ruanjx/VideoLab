//
//  PHAssetVideoSource.swift
//  VideoLab
//
//  Created by Bear on 2020/8/29.
//

import AVFoundation
import Photos

public class PHAssetVideoSource: Source {
    private var asset: AVAsset?
    private var phAsset: PHAsset?
    
    public init(phAsset: PHAsset) {
        self.phAsset = phAsset
        selectedTimeRange = CMTimeRange.zero
        duration = CMTime.zero
    }
    
    // MARK: - Source
    public var selectedTimeRange: CMTimeRange
    
    public var duration: CMTime
    
    public var isLoaded: Bool = false
    
    public func load(completion: @escaping (NSError?) -> Void) {
        guard let phAsset = phAsset else {
            let error = NSError.init(domain: "com.source.load",
                                     code: 0,
                                     userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("PHAsset is nil", comment: "")])
            completion(error)
            return
        }
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { [weak self] (asset, audioMix, info) in
            guard let self = self else { return }
            
            defer {
                self.isLoaded = true
            }

            guard let asset = asset else {
                let error = NSError.init(domain: "com.source.load",
                                         code: 0,
                                         userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("PHAsset loaded, but generate nil AVAsset", comment: "")])
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
           
            self.asset = asset
            if let videoTrack = asset.tracks(withMediaType: .video).first {
                // Make sure source's duration not beyond video track's duration
                self.duration = videoTrack.timeRange.duration
            } else {
                self.duration = asset.duration
            }
            self.selectedTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: self.duration)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    public func tracks(for type: AVMediaType) -> [AVAssetTrack] {
        guard isLoaded else {
            fatalError("PHAssetVideoSource must be loaded before use")
        }

        guard let asset = asset else { return [] }
        return asset.tracks(withMediaType: type)
    }
}
