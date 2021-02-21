//
//  Position.swift
//  VideoLab
//
//  Created by Bear on 2020/8/20.
//  Copyright (c) 2020 Chocolate. All rights reserved.
//

import Foundation

public struct Position {
    public let x:Float
    public let y:Float
    public let z:Float?
    
    public init (_ x:Float, _ y:Float, _ z:Float? = nil) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public static let center = Position(0.5, 0.5)
    public static let zero = Position(0.0, 0.0)
}


public struct Position2D {
    public let x:Float
    public let y:Float
    
    public init (_ x:Float, _ y:Float) {
        self.x = x
        self.y = y
    }
    
    public static let center = Position2D(0.5, 0.5)
    public static let zero = Position2D(0.0, 0.0)
}
