//
//  VideoRenderLayer.swift
//  VideoLab
//
//  Created by Bear on 2020/8/29.
//

import AVFoundation

class VideoRenderLayer {
    let renderLayer: RenderLayer
    var trackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    var timeRangeInTimeline: CMTimeRange
    var preferredTransform: CGAffineTransform = CGAffineTransform.identity
    
    init(renderLayer: RenderLayer) {
        self.renderLayer = renderLayer
        timeRangeInTimeline = renderLayer.timeRange
    }
    
    func addVideoTrack(to composition: AVMutableComposition, preferredTrackID: CMPersistentTrackID) {
        guard let source = renderLayer.source else {
            return
        }
        guard let assetTrack = source.tracks(for: .video).first else {
            return
        }
        preferredTransform = assetTrack.preferredTransform

        let compositionTrack: AVMutableCompositionTrack? = {
            if let compositionTrack = composition.track(withTrackID: preferredTrackID) {
                return compositionTrack
            }
            return composition.addMutableTrack(withMediaType: .video, preferredTrackID: preferredTrackID)
        }()

        if let compositionTrack = compositionTrack {
            do {
                try compositionTrack.insertTimeRange(source.selectedTimeRange, of:assetTrack , at: timeRangeInTimeline.start)
            } catch {
                // TODO: handle Error
            }
        }
    }

    class func addBlankVideoTrack(to composition: AVMutableComposition, in timeRange: CMTimeRange, preferredTrackID: CMPersistentTrackID) {
        guard let assetTrack = blankVideoAsset?.tracks(withMediaType: .video).first else {
            return
        }

        let compositionTrack: AVMutableCompositionTrack? = {
            if let compositionTrack = composition.track(withTrackID: preferredTrackID) {
                return compositionTrack
            }
            return composition.addMutableTrack(withMediaType: .video, preferredTrackID: preferredTrackID)
        }()
        
        var insertTimeRange = assetTrack.timeRange
        if insertTimeRange.duration > timeRange.duration {
            insertTimeRange.duration = timeRange.duration
        }
        
        if let compositionTrack = compositionTrack {
            do {
                try compositionTrack.insertTimeRange(insertTimeRange, of:assetTrack , at: timeRange.start)
                compositionTrack.scaleTimeRange(CMTimeRange(start: timeRange.start, duration: insertTimeRange.duration), toDuration: timeRange.duration)
            } catch {
                // TODO: handle Error
            }
        }
    }
    
    // MARK: - Private
    private static let blankVideoAsset: AVAsset? = {
        let bundle = Bundle(for: VideoRenderLayer.self)
        guard let bundleURL = bundle.url(forResource: "VideoLab", withExtension: "bundle") else {
            return nil
        }
        
        let resourceBundle = Bundle.init(url: bundleURL)
        guard let videoURL = resourceBundle?.url(forResource: "BlankVideo", withExtension: "mov") else {
            return nil
        }
        
        return AVAsset(url: videoURL)
    }()
}

extension RenderLayer {
    @objc func canBeConvertedToVideoRenderLayer() -> Bool {
        if source?.tracks(for: .video).first != nil {
            return true
        }
        if source is ImageSource {
            return true
        }
        if operations.count > 0 {
            return true
        }
        
        return false
    }
}
