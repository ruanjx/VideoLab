//
//  UIColor+Extension.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/8/29.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

extension UIColor {

    static func hexIntToColorRGB(hexInt: Int) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
            let red: CGFloat = CGFloat(hexInt >> 16)
            let green: CGFloat = CGFloat((hexInt & 0xFF00) >> 8)
            let blue: CGFloat = CGFloat(hexInt & 0xFF)
            return (red, green, blue)
        }
    
    static func hexStringToColorRGB(hexString: String) -> (r: CGFloat?, g: CGFloat?, b: CGFloat?) {
            // 1、判断字符串的长度是否符合
            guard hexString.count >= 6 else {
                return (nil, nil, nil)
            }
            // 2、将字符串转成大写
            var tempHex = hexString.uppercased()
            // 检查字符串是否拥有特定前缀
            // hasPrefix(prefix: String)
            // 检查字符串是否拥有特定后缀。
            // hasSuffix(suffix: String)
            // 3、判断开头： 0x/#/##
            if tempHex.hasPrefix("0x") || tempHex.hasPrefix("##") {
                tempHex = String(tempHex[tempHex.index(tempHex.startIndex, offsetBy: 2)..<tempHex.endIndex])
            }
            if tempHex.hasPrefix("#") {
                tempHex = String(tempHex[tempHex.index(tempHex.startIndex, offsetBy: 1)..<tempHex.endIndex])
            }
            // 4、分别取出 RGB
            // FF --> 255
            var range = NSRange(location: 0, length: 2)
            let rHex = (tempHex as NSString).substring(with: range)
            range.location = 2
            let gHex = (tempHex as NSString).substring(with: range)
            range.location = 4
            let bHex = (tempHex as NSString).substring(with: range)
            // 5、将十六进制转成 255 的数字
            var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
            Scanner(string: rHex).scanHexInt32(&r)
            Scanner(string: gHex).scanHexInt32(&g)
            Scanner(string: bHex).scanHexInt32(&b)
            return (r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
        }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
            self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
        }
    
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
            let color = Self.hexStringToColorRGB(hexString: hexString)
            guard let r = color.r, let g = color.g, let b = color.b else {
                #if DEBUG
                assert(false, "不是十六进制值")
                #endif
                return nil
            }
            self.init(r: r, g: g, b: b, alpha: alpha)
        }
    
    convenience init(hexInt: Int, alpha: CGFloat = 1.0) {
        let color = Self.hexIntToColorRGB(hexInt: hexInt)
            self.init(r: color.r, g: color.g, b: color.b, alpha: alpha)
        }
}
