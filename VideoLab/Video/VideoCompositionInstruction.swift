//
//  VideoCompositionInstruction.swift
//  VideoLab
//
//  Created by Bear on 2020/8/29.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import AVFoundation

class VideoCompositionInstruction: NSObject, AVVideoCompositionInstructionProtocol {
    var timeRange: CMTimeRange
    var enablePostProcessing: Bool
    var containsTweening: Bool
    var requiredSourceTrackIDs: [NSValue]?
    var passthroughTrackID: CMPersistentTrackID

    var videoRenderLayers: [VideoRenderLayer] = []

    init(videoRenderLayers: [VideoRenderLayer], timeRange: CMTimeRange) {
        self.timeRange = timeRange
        enablePostProcessing = true
        containsTweening = true
        passthroughTrackID = kCMPersistentTrackID_Invalid
        
        super.init()
        
        self.videoRenderLayers = videoRenderLayers
        
        var trackIDSet: Set<CMPersistentTrackID> = []
        videoRenderLayers.forEach { videoRenderLayer in
            if let videoRenderLayerGroup = videoRenderLayer as? VideoRenderLayerGroup {
                let recursiveTrackIDs = videoRenderLayerGroup.recursiveTrackIDs()
                trackIDSet = trackIDSet.union(Set(recursiveTrackIDs))
            } else {
                trackIDSet.insert(videoRenderLayer.trackID)
            }
        }
        requiredSourceTrackIDs = Array(trackIDSet)
            .filter { $0 != kCMPersistentTrackID_Invalid }
            .compactMap { $0 as NSValue }
    }
}
