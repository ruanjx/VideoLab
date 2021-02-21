//
//  Color.swift
//  VideoLab
//
//  Created by Bear on 2020/8/20.
//  Copyright (c) 2020 Chocolate. All rights reserved.
//

import Foundation
import Metal

public struct Color {
    public let red:Float
    public let green:Float
    public let blue:Float
    public let alpha:Float
    
    public init(red:Float, green:Float, blue:Float, alpha:Float = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public static let black = Color(red:0.0, green:0.0, blue:0.0, alpha:1.0)
    public static let white = Color(red:1.0, green:1.0, blue:1.0, alpha:1.0)
    public static let red = Color(red:1.0, green:0.0, blue:0.0, alpha:1.0)
    public static let green = Color(red:0.0, green:1.0, blue:0.0, alpha:1.0)
    public static let blue = Color(red:0.0, green:0.0, blue:1.0, alpha:1.0)
    public static let transparent = Color(red:0.0, green:0.0, blue:0.0, alpha:0.0)
    
    public static var clearColor = Color.black
    public static var mtlClearColor: MTLClearColor {
        get {
            return MTLClearColorMake(Double(clearColor.red), Double(clearColor.green), Double(clearColor.blue), Double(clearColor.alpha))
        }
    }
}
