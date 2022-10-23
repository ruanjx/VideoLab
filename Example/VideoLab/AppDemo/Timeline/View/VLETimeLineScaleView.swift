//
//  VLETimeLineView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/8/30.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit

class VLETimeLineScaleView: UIView {
    
    var model: VLETimeLineStateModel
    var layerArray:[CALayer] = []
    
    init(model: VLETimeLineStateModel) {
        self.model = model
        super.init(frame: CGRect.zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func refreshTimeWith(seconds: Float){
        removeAllLayer()
        reloadScale()
    }

    private func removeAllLayer() {
        for item in layerArray {
            item.removeFromSuperlayer()
        }
        layerArray.removeAll()
    }

    private func reloadScale() {
        let spaceWidth = self.model.fetchScaleSpaceWidth()
        var sumWidth = self.model.fetchScaleViewWidth()
        var girdX = self.bounds.origin.x
        let girdY = self.bounds.size.height/2
        var index = 0
        var second = 0
        while (sumWidth >= 0) {
            if index == 0 || index == 3 {
                index = 0
                let timeTextStr = VLETimeLineConfig.secondsToMinutesSeconds(sourceSeconds: second)
                let timeTextLayer = makeTextLayer(frame: CGRect.init(x: girdX-28/2, y: 0, width: 28, height: 14), text: timeTextStr)
                self.layer.addSublayer(timeTextLayer)
                layerArray.append(timeTextLayer)
            } else {
                let circleLayer = makeCircleLayer(center: CGPoint.init(x: girdX, y: girdY))
                self.layer.addSublayer(circleLayer)
                layerArray.append(circleLayer)
            }
            index += 1
            second += 1
            sumWidth -= spaceWidth
            girdX += spaceWidth
        }
    }

    private func makeTextLayer(frame: CGRect, text: String) -> CATextLayer {
        let textLayer: CATextLayer = CATextLayer.init()
        textLayer.frame = frame
        textLayer.foregroundColor = UIColor.init(hexString: "#BABABA")?.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        let font = UIFont.systemFont(ofSize: 10)
        textLayer.font = CGFont.init(font.fontName as CFString)
        textLayer.fontSize = font.pointSize
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.string = text
        return textLayer
    }

    private func makeCircleLayer(center: CGPoint) -> CAShapeLayer {
        let circle: CAShapeLayer = CAShapeLayer.init()
        let path: UIBezierPath = UIBezierPath.init(arcCenter: center, radius: 2, startAngle: 0, endAngle: .pi*2, clockwise: true)
        circle.lineWidth = 1
        circle.fillColor = UIColor.init(hexString: "#D8D8D8")?.cgColor
        circle.path = path.cgPath
        return circle
    }
}
