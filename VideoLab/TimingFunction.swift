//
//  TimingFunction.swift
//  VideoLab
//
//  Created by Bear on 2020/8/10.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import CoreMedia

public enum TimingFunction: Int {
    // Linear interpolation (no easing)
    case linear
    
    // Quadratic easing p^2
    case quadraticEaseIn
    case quadraticEaseOut
    case quadraticEaseInOut
    
    // Cubic easing p^3
    case cubicEaseIn
    case cubicEaseOut
    case cubicEaseInOut
    
    // Quartic easing p^4
    case quarticEaseIn
    case quarticEaseOut
    case quarticEaseInOut
    
    // Quartic easing p^5
    case quinticEaseIn
    case quinticEaseOut
    case quinticEaseInOut
    
    // Sine wave easing sin(p * PI/2)
    case sineEaseIn
    case sineEaseOut
    case sineEaseInOut
    
    // Circular easing sqrt(1 - p^2)
    case circularEaseIn
    case circularEaseOut
    case circularEaseInOut
    
    // Exponential easing base 2
    case exponentialEaseIn
    case exponentialEaseOut
    case exponentialEaseInOut
    
    // Exponentially-damped sine wave easing
    case elasticEaseIn
    case elasticEaseOut
    case elasticEaseInOut
    
    // Overshooting cubic easing
    case backEaseIn
    case backEaseOut
    case backEaseInOut
    
    // Exponentially-decaying bounce easing
    case bounceEaseIn
    case bounceEaseOut
    case bounceEaseInOut
    
    public func value(at progress: Float) -> Float {
        switch self {
        case .linear:
            return linearInterpolation(p: progress)
            
        case .quadraticEaseIn:
            return quadraticEaseInValue(p: progress)
        case .quadraticEaseOut:
            return quadraticEaseOutValue(p: progress)
        case .quadraticEaseInOut:
            return quadraticEaseInOutValue(p: progress)

        case .cubicEaseIn:
            return cubicEaseInValue(p: progress)
        case .cubicEaseOut:
            return cubicEaseOutValue(p: progress)
        case .cubicEaseInOut:
            return cubicEaseInOutValue(p: progress)

        case .quarticEaseIn:
            return quarticEaseInValue(p: progress)
        case .quarticEaseOut:
            return quarticEaseOutValue(p: progress)
        case .quarticEaseInOut:
            return quarticEaseInOutValue(p: progress)
            
        case .quinticEaseIn:
            return quinticEaseInValue(p: progress)
        case .quinticEaseOut:
            return quinticEaseOutValue(p: progress)
        case .quinticEaseInOut:
            return quinticEaseInOutValue(p: progress)
            
        case .sineEaseIn:
            return sineEaseInValue(p: progress)
        case .sineEaseOut:
            return sineEaseOutValue(p: progress)
        case .sineEaseInOut:
            return sineEaseInOutValue(p: progress)

        case .circularEaseIn:
            return circularEaseInValue(p: progress)
        case .circularEaseOut:
            return circularEaseOutValue(p: progress)
        case .circularEaseInOut:
            return circularEaseInOutValue(p: progress)

        case .exponentialEaseIn:
            return exponentialEaseInValue(p: progress)
        case .exponentialEaseOut:
            return exponentialEaseOutValue(p: progress)
        case .exponentialEaseInOut:
            return exponentialEaseInOutValue(p: progress)
            
        case .elasticEaseIn:
            return elasticEaseInValue(p: progress)
        case .elasticEaseOut:
            return elasticEaseOutValue(p: progress)
        case .elasticEaseInOut:
            return elasticEaseInOutValue(p: progress)
            
        case .backEaseIn:
            return backEaseInValue(p: progress)
        case .backEaseOut:
            return backEaseOutValue(p: progress)
        case .backEaseInOut:
            return backEaseInOutValue(p: progress)
            
        case .bounceEaseIn:
            return bounceEaseInValue(p: progress)
        case .bounceEaseOut:
            return bounceEaseOutValue(p: progress)
        case .bounceEaseInOut:
            return bounceEaseInOutValue(p: progress)
        }
    }
    
    private func linearInterpolation(p: Float) -> Float {
        return p
    }
    
    private func quadraticEaseInValue(p: Float) -> Float {
        return p * p
    }
    private func quadraticEaseOutValue(p: Float) -> Float {
        return -(p * (p - 2))
    }
    private func quadraticEaseInOutValue(p: Float) -> Float {
        if p < 0.5 {
            return 2 * p * p
        } else {
            return (-2 * p * p) + (4 * p) - 1
        }
    }
    
    private func cubicEaseInValue(p: Float) -> Float {
        return p * p * p
    }
    private func cubicEaseOutValue(p: Float) -> Float {
        let f = (p - 1)
        return f * f * f + 1
    }
    private func cubicEaseInOutValue(p: Float) -> Float {
        if p < 0.5 {
            return 4 * p * p * p
        } else {
            let f = ((2 * p) - 2)
            return 0.5 * f * f * f + 1
        }
    }
    
    private func quarticEaseInValue(p: Float) -> Float {
        return p * p * p * p
    }
    private func quarticEaseOutValue(p: Float) -> Float {
        let f = (p - 1)
        return f * f * f * (1 - p) + 1
    }
    private func quarticEaseInOutValue(p: Float) -> Float {
        if p < 0.5 {
            return 8 * p * p * p * p
        } else {
            let f = (p - 1)
            return -8 * f * f * f * f + 1
        }
    }
    
    private func quinticEaseInValue(p: Float) -> Float {
        return p * p * p * p * p
    }
    private func quinticEaseOutValue(p: Float) -> Float {
        let f = (p - 1)
        return f * f * f * f * f + 1
    }
    private func quinticEaseInOutValue(p: Float) -> Float {
        if p < 0.5 {
            return 16 * p * p * p * p * p
        } else {
            let f = ((2 * p) - 2)
            return 0.5 * f * f * f * f * f + 1
        }
    }
    
    private func sineEaseInValue(p: Float) -> Float {
        return sin((p - 1) * Float.pi) + 1
    }
    private func sineEaseOutValue(p: Float) -> Float {
        return sin(p * Float.pi / 2)
    }
    private func sineEaseInOutValue(p: Float) -> Float {
        return 0.5 * (1 - cos(p * Float.pi))
    }
    
    private func circularEaseInValue(p: Float) -> Float {
        return 1 - sqrt(1 - (p * p))
    }
    private func circularEaseOutValue(p: Float) -> Float {
        return sqrt((2 - p) * p)
    }
    private func circularEaseInOutValue(p: Float) -> Float {
        if p < 0.5 {
            return 0.5 * (1 - sqrt(1 - 4 * (p * p)))
        } else {
            return 0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1)
        }
    }
    
    private func exponentialEaseInValue(p: Float) -> Float {
        return (p == 0.0) ? p : pow(2, 10 * (p - 1))
    }
    private func exponentialEaseOutValue(p: Float) -> Float {
        return (p == 1.0) ? p : 1 - pow(2, -10 * p)
    }
    private func exponentialEaseInOutValue(p: Float) -> Float {
        if p == 0.0 || p == 1.0 {
            return p
        }
        
        if p < 0.5 {
            return 0.5 * pow(2, (20 * p) - 10)
        } else {
            return -0.5 * pow(2, (-20 * p) + 10) + 1
        }
    }
    
    private func elasticEaseInValue(p: Float) -> Float {
        return sin(13 * Float.pi / 2 * p) * pow(2, 10 * (p - 1))
    }
    private func elasticEaseOutValue(p: Float) -> Float {
        return sin(-13 * Float.pi / 2 * (p + 1)) * pow(2, -10 * p) + 1
    }
    private func elasticEaseInOutValue(p: Float) -> Float {
        if p < 0.5 {
            return 0.5 * sin(13 * Float.pi / 2 * (2 * p)) * pow(2, 10 * ((2 * p) - 1))
        } else {
            return 0.5 * (sin(-13 * Float.pi / 2 * ((2 * p - 1) + 1)) * pow(2, -10 * (2 * p - 1)) + 2)
        }
    }
    
    private func backEaseInValue(p: Float) -> Float {
        return p * p * p - p * sin(p * Float.pi)
    }
    private func backEaseOutValue(p: Float) -> Float {
        let f = (1 - p);
        return 1 - (f * f * f - f * sin(f * Float.pi))
    }
    private func backEaseInOutValue(p: Float) -> Float {
        if p < 0.5 {
            let f = 2 * p
            return 0.5 * (f * f * f - f * sin(f * Float.pi))
        } else {
            let f = (1 - (2 * p - 1))
            return 0.5 * (1 - (f * f * f - f * sin(f * Float.pi))) + 0.5
        }
    }
    
    private func bounceEaseInValue(p: Float) -> Float {
        return 1 - bounceEaseOutValue(p: 1 - p)
    }
    private func bounceEaseOutValue(p: Float) -> Float {
        if p < 4/11.0 {
            return (121 * p * p)/16.0
        } else if p < 8/11.0 {
            return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0
        } else if p < 9/10.0 {
            return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0
        } else {
            return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0
        }
    }
    private func bounceEaseInOutValue(p: Float) -> Float {
        if p < 0.5 {
            return 0.5 * bounceEaseInValue(p: p * 2)
        } else {
            return 0.5 * bounceEaseOutValue(p: p * 2 - 1) + 0.5
        }
    }
}
