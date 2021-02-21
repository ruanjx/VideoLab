//
//  AudioConfiguration.swift
//  VideoLab
//
//  Created by Bear on 2020/8/9.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import AVFoundation

public struct AudioConfiguration {
    public var pitchAlgorithm: AVAudioTimePitchAlgorithm = .varispeed
    public var volumeRamps: [VolumeRamp] = []
    
    public init(pitchAlgorithm: AVAudioTimePitchAlgorithm = .varispeed, volumeRamps: [VolumeRamp] = []) {
        self.pitchAlgorithm = pitchAlgorithm
        self.volumeRamps = volumeRamps
    }
}

public struct VolumeRamp {
    public var startVolume: Float
    public var endVolume: Float
    public var timeRange: CMTimeRange
    public var timingFunction: TimingFunction = .linear
    
    public init(startVolume: Float, endVolume: Float, timeRange: CMTimeRange, timingFunction: TimingFunction = .linear) {
        self.startVolume = startVolume
        self.endVolume = endVolume
        self.timeRange = timeRange
        self.timingFunction = timingFunction
    }
}
