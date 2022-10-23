//
//  PHAssetImageSource.swift
//  VideoLab
//
//  Created by Bear on 2020/8/1.
//

import AVFoundation
import Photos

public class PHAssetImageSource: ImageSource {
    private var phAsset: PHAsset?

    public init(phAsset: PHAsset) {
        super.init()
        self.phAsset = phAsset
    }
    
    public override func copy() -> Source {
        let source = PHAssetImageSource.init(phAsset: self.phAsset!)
        source.isLoaded = false
        return source
    }
    
    // MARK: - Source
    override public func load(completion: @escaping (NSError?) -> Void) {
        guard let phAsset = phAsset else {
            let error = NSError(domain: "com.source.load",
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("PHAsset is nil", comment: "")])
            completion(error)
            return
        }
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: phAsset, targetSize: CGSize(width: phAsset.pixelWidth, height: phAsset.pixelHeight), contentMode: .aspectFill, options: options) { [weak self] (image, info) in
            guard let self = self else { return }
            if let error = info?[PHImageErrorKey] as? NSError {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
            
            if let cgImage = image?.cgImage {
//                defer {
                    self.isLoaded = true
//                }
                self.texture = Texture.makeTexture(cgImage: cgImage)
                completion(nil);
            } else {
                let error = NSError(domain: "com.source.load",
                                    code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("PHAsset loaded, but can't find image", comment: "")])
                completion(error)
            }
        }
    }
    
    override public func texture(at time: CMTime) -> Texture? {
        guard isLoaded else {
            fatalError("PHAssetImageSource must be loaded before use")
        }
        
        return super.texture(at: time)
    }
}
