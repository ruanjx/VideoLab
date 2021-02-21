//
//  AudioRenderLayer.swift
//  VideoLab
//
//  Created by Bear on 2020/8/9.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import AVFoundation
import Accelerate

class AudioRenderLayer {
    let renderLayer: RenderLayer
    var superLayer: AudioRenderLayer?
    var trackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    var timeRangeInTimeline: CMTimeRange
    var pitchAlgorithm: AVAudioTimePitchAlgorithm? {
        return renderLayer.audioConfiguration.pitchAlgorithm
    }

    init(renderLayer: RenderLayer) {
        self.renderLayer = renderLayer
        timeRangeInTimeline = renderLayer.timeRange
    }
    
    func addAudioTrack(to composition: AVMutableComposition, preferredTrackID: CMPersistentTrackID) {
        guard let source = renderLayer.source else {
            return
        }
        guard let assetTrack = source.tracks(for: .audio).first else {
            return
        }
        
        let compositionTrack: AVMutableCompositionTrack? = {
            if let compositionTrack = composition.track(withTrackID: preferredTrackID) {
                return compositionTrack
            }
            return composition.addMutableTrack(withMediaType: .audio, preferredTrackID: preferredTrackID)
        }()
        
        if let compositionTrack = compositionTrack {
            do {
                try compositionTrack.insertTimeRange(source.selectedTimeRange, of:assetTrack , at: timeRangeInTimeline.start)
            } catch {
                // TODO: handle Error
            }
        }
    }
    
    func makeAudioTapProcessor() -> MTAudioProcessingTap? {
        guard renderLayer.canBeConvertedToAudioRenderLayer() else {
            return nil
        }
        
        var callbacks = MTAudioProcessingTapCallbacks(
            version: kMTAudioProcessingTapCallbacksVersion_0,
            clientInfo: UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque()),
            init: tapInit,
            finalize: tapFinalize,
            prepare: nil,
            unprepare: nil,
            process: tapProcess)
        
        var tap: Unmanaged<MTAudioProcessingTap>?
        let status = MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PostEffects, &tap)
        if status != noErr {
            print("Failed to create audio processing tap")
        }
        return tap?.takeRetainedValue()
    }

    // MARK: - Private
    
    private func processAudio(_ bufferListInOut: UnsafeMutablePointer<AudioBufferList>, timeRange: CMTimeRange) {
        guard timeRange.duration.isValid else {
            return
        }
        if timeRangeInTimeline.intersection(timeRange).isEmpty {
            return
        }
        
        let volumeRamps = renderLayer.audioConfiguration.volumeRamps
        if volumeRamps.count > 0 {
            let processTime = timeRange.end.seconds - timeRangeInTimeline.start.seconds
            var processVolumeRamp: VolumeRamp?
            for volumeRamp in volumeRamps {
                if processTime < volumeRamp.timeRange.start.seconds {
                    break
                }
                processVolumeRamp = volumeRamp
            }
            
            if let processVolumeRamp = processVolumeRamp {
                let startTimeValue = processVolumeRamp.timeRange.start.seconds
                let endTimeValue = processVolumeRamp.timeRange.end.seconds
                var progress = (processTime - startTimeValue) / (endTimeValue - startTimeValue)
                if progress > 1.0 {
                    progress = 1.0
                }
                let normalizedValue = processVolumeRamp.timingFunction.value(at: Float(progress))
                let startVolume = processVolumeRamp.startVolume
                let endVolume = processVolumeRamp.endVolume
                let volume = startVolume + normalizedValue * (endVolume - startVolume)

                changeAudio(bufferListInOut, volume: volume)
            }
        }

        if let superLayer = superLayer {
            superLayer.processAudio(bufferListInOut, timeRange: timeRange)
        }
    }
    
    private func changeAudio(_ bufferListInOut: UnsafeMutablePointer<AudioBufferList>, volume: Float) {
        let bufferList = UnsafeMutableAudioBufferListPointer(bufferListInOut)
        for bufferIndex in 0..<bufferList.count {
            let audioBuffer = bufferList[bufferIndex]
            if let rawBuffer = audioBuffer.mData {
                let floatRawPointer = rawBuffer.assumingMemoryBound(to: Float.self)
                let frameCount = UInt(audioBuffer.mDataByteSize) / UInt(MemoryLayout<Float>.size)
                var volume = volume
                vDSP_vsmul(floatRawPointer, 1, &volume, floatRawPointer, 1, frameCount)
            }
        }
    }

    // MARK: - MTAudioProcessingTapCallbacks
    
    private let tapInit: MTAudioProcessingTapInitCallback = { (tap, clientInfo, tapStorageOut) in
        tapStorageOut.pointee = clientInfo
    }
    
    let tapFinalize: MTAudioProcessingTapFinalizeCallback = { (tap) in
        Unmanaged<AudioRenderLayer>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).release()
    }

    private let tapProcess: MTAudioProcessingTapProcessCallback = { (tap, numberFrames, flags, bufferListInOut, numberFramesOut, flagsOut) in
        var timeRange: CMTimeRange = CMTimeRange.zero
        let status = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut, flagsOut, &timeRange, numberFramesOut)
        if status != noErr {
            print("Failed to get source audio")
            return
        }
        
        let audioRenderLayer = Unmanaged<AudioRenderLayer>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).takeUnretainedValue()
        audioRenderLayer.processAudio(bufferListInOut, timeRange: timeRange)
    }
}

extension RenderLayer {
    @objc func canBeConvertedToAudioRenderLayer() -> Bool {
        return source?.tracks(for: .audio).first != nil
    }
}
