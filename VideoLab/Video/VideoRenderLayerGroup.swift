//
//  VideoRenderLayerGroup.swift
//  VideoLab
//
//  Created by Bear on 2020/8/13.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import AVFoundation

class VideoRenderLayerGroup: VideoRenderLayer {
    var videoRenderLayers: [VideoRenderLayer] = []
    private var recursiveVideoRenderLayersInGroup: [VideoRenderLayer] = []

    override init(renderLayer: RenderLayer) {
        super.init(renderLayer: renderLayer)
        generateVideoRenderLayers()
    }

    // MARK: - Public
    
    public func recursiveVideoRenderLayers() -> [VideoRenderLayer] {
        var recursiveVideoRenderLayers: [VideoRenderLayer] = []
        for videoRenderLayer in videoRenderLayers {
            videoRenderLayer.timeRangeInTimeline.start = CMTimeAdd(videoRenderLayer.timeRangeInTimeline.start, timeRangeInTimeline.start)
            if let videoRenderLayerGroup = videoRenderLayer as? VideoRenderLayerGroup {
                recursiveVideoRenderLayers += videoRenderLayerGroup.recursiveVideoRenderLayers()
            } else {
                recursiveVideoRenderLayers.append(videoRenderLayer)
            }
        }
        self.recursiveVideoRenderLayersInGroup = recursiveVideoRenderLayers
        
        return recursiveVideoRenderLayers
    }
    
    public func recursiveTrackIDs() -> [CMPersistentTrackID] {
        return recursiveVideoRenderLayersInGroup.compactMap { $0.trackID }
    }
    
    // MARK: - Private
    
    private func generateVideoRenderLayers() {
        guard let renderLayerGroup = renderLayer as? RenderLayerGroup else {
            return
        }

        for subRenderLayer in renderLayerGroup.layers {
            if subRenderLayer is RenderLayerGroup {
                videoRenderLayers.append(VideoRenderLayerGroup(renderLayer: subRenderLayer))
            } else if subRenderLayer.canBeConvertedToVideoRenderLayer() {
                videoRenderLayers.append(VideoRenderLayer(renderLayer: subRenderLayer))
            }
        }
    }
}

extension VideoRenderLayer {
    class func makeVideoRenderLayer(renderLayer: RenderLayer) -> VideoRenderLayer {
        if  renderLayer is RenderLayerGroup {
            return VideoRenderLayerGroup(renderLayer: renderLayer)
        } else {
            return VideoRenderLayer(renderLayer: renderLayer)
        }
    }
}

extension RenderLayerGroup {
    override func canBeConvertedToVideoRenderLayer() -> Bool {
        for renderLayer in layers {
            if renderLayer.canBeConvertedToVideoRenderLayer() {
                return true
            }
        }
        return false
    }
}
