//
//  KeyframeAnimation.swift
//  VideoLab
//
//  Created by Bear on 2020/8/13.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import CoreMedia

public struct KeyframeAnimation {
    /// The key-path describing the property to be animated.
    public var keyPath: String
    
    /// An array providing the value of the animation function for each keyframe.
    public var values: [Float]
    
    /// An array of `CMTime' objects defining the pacing of the animation.
    /// Each time corresponds to one value in the `values' array, time is based on layer time.
    public var keyTimes: [CMTime]
    
    /// An optional array of TimingFunction objects.
    /// If the `values' array defines n keyframes, there should be n-1 objects in the `timingFunctions' array
    public var timingFunctions: [TimingFunction]
    
    /// Create a KeyframeAnimation with keyPath, values, keyTimes, timingFunctions
    public init(keyPath: String, values: [Float], keyTimes: [CMTime], timingFunctions: [TimingFunction]) {
        self.keyPath = keyPath
        self.values = values
        self.keyTimes = keyTimes
        self.timingFunctions = timingFunctions
    }

    /// The value at the corresponding time, time is based on layer time.
    public func value(at time: CMTime) -> Float? {
        let timeValue = time.seconds
        for index in 0..<keyTimes.count - 1 {
            let startTimeValue = keyTimes[index].seconds
            let endTimeValue = keyTimes[index + 1].seconds
            
            // Less than the minimum time
            if index == 0 && timeValue < startTimeValue {
                return values[0]
            }
            
            // Greater than maximum time
            if index == keyTimes.count - 2 && timeValue > endTimeValue {
                return values[index + 1]
            }
            
            if timeValue >= startTimeValue && timeValue <= endTimeValue {
                let progress = Float(timeValue - startTimeValue) / Float(endTimeValue - startTimeValue)
                let timingFunction = timingFunctions[index]
                let normalizedValue = timingFunction.value(at: progress)
                let fromValue = values[index]
                let toValue = values[index + 1]
                let value = fromValue + normalizedValue * (toValue - fromValue)
                return value
            }
        }
        
        return nil
    }
    
    public static func value(for keyPath: String, at time: CMTime, animations: [KeyframeAnimation]?) -> Float? {
        guard let animations = animations else {
            return nil
        }
        
        for animation in animations {
            if animation.keyPath == keyPath {
                if let value = animation.value(at: time) {
                    return value
                }
            }
        }
        
        return nil
    }
}

public protocol Animatable {
    var animations: [KeyframeAnimation]? { get set }
    mutating func updateAnimationValues(at time: CMTime)
}
