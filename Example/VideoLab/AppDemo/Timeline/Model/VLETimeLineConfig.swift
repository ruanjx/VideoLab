//
//  VLETimeLineConfigModel.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/10.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import CoreMedia
import UIKit

class VLETimeLineConfig {
    
    static let framesPerSecond: Float = 30
    static let ptPerFrames: CGFloat = 1
    static let frontMargin: CGFloat = UIScreen.main.bounds.width/2
    static let backMargin: CGFloat = UIScreen.main.bounds.width/2
    static let framesPerSpace: Int = 30

    class func convertToSecond(value time: CMTime) -> Float {
        return Float(time.value)/Float(time.timescale)
    }
    
    class func convertToPt(value second: Float) -> CGFloat {
        return CGFloat.init(second) * CGFloat.init(VLETimeLineConfig.framesPerSecond) * VLETimeLineConfig.ptPerFrames
    }

    class func convertToPt(value time: CMTime) -> CGFloat {
        return convertToPt(value: VLETimeLineConfig.convertToSecond(value: time))
    }

    class func convertToSecond(value pt: CGFloat) -> Float {
        return Float(pt/VLETimeLineConfig.ptPerFrames)/framesPerSecond
    }

    class func secondsToMinutesSeconds(sourceSeconds: Int) -> String {
        let minute = (sourceSeconds % 3600) / 60
        let second = (sourceSeconds % 3600) % 60
        let mStr = minute >= 10 ? String(minute) : "0"+String(minute)
        let sStr = second >= 10 ? String(second) : "0"+String(second)
        return "\(mStr):\(sStr)"
    }

}
