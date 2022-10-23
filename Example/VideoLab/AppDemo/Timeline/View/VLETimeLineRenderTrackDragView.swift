//
//  VLETimeLineRenderTrackDragView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/10/12.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import CoreMedia

protocol VLETimeLineRenderTrackDragViewDelegate: NSObjectProtocol {
    func renderTrackDragView(_ dragView: VLETimeLineRenderTrackDragView, targetView: VLETimeLineRenderTrackSegmentView, leftBorderDragWith offsetX: CGFloat, finalWidth: CGFloat)
    func renderTrackDragView(_ dragView: VLETimeLineRenderTrackDragView, targetView: VLETimeLineRenderTrackSegmentView, rightBorderDragWith offsetX: CGFloat, finalWidth: CGFloat)
    func renderTrackDragViewIsDragEnd()
}

class VLETimeLineRenderTrackDragView: UIView {
    
    var viewW: CGFloat = 0
    var targetViewW: CGFloat = 0
    var panGestureOriginX: CGFloat = 0
    let targetView: VLETimeLineRenderTrackSegmentView
    var originalSelectedDurtaion: CMTime = CMTime.zero
    var originalGlobalStartTime: CMTime = CMTime.zero
    var originalSelectedStartTime: CMTime = CMTime.zero
    weak var delegate: VLETimeLineRenderTrackDragViewDelegate?
    
    lazy var leftDragBlockView: UIView = {
        let view = UIView.init()
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(leftDragBlockViewGestureAction(sender:)))
        view.addGestureRecognizer(gesture)
        view.backgroundColor = UIColor.clear
        return view
    }()

    lazy var rightDragBlockView: UIView = {
        let view = UIView.init()
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(rightDragBlockViewGestureAction(sender:)))
        view.addGestureRecognizer(gesture)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var middleAreaView: UIView = {
        let view = UIView.init()
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(middleAreaViewTapGestureAction(sender:)))
        view.addGestureRecognizer(gesture)
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    init(delegate: VLETimeLineRenderTrackDragViewDelegate, targetView: VLETimeLineRenderTrackSegmentView) {
        self.targetView = targetView
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        self.addSubview(leftDragBlockView)
        self.addSubview(rightDragBlockView)
        self.addSubview(middleAreaView)
        leftDragBlockView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.width.equalTo(24)
        }
        rightDragBlockView.snp.makeConstraints { make in
            make.right.top.height.equalToSuperview()
            make.width.equalTo(24)
        }
        middleAreaView.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
            make.left.equalTo(leftDragBlockView.snp.right).offset(0)
            make.right.equalTo(rightDragBlockView.snp.left).offset(0)
        }
        addDragBlockRoundCornerLayer(isLeft: true)
        addDragBlockRoundCornerLayer(isLeft: false)
        addDragBlockArrowLayer(isLeft: true)
        addDragBlockArrowLayer(isLeft: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    @objc func middleAreaViewTapGestureAction(sender: UITapGestureRecognizer) {
    }

    @objc func leftDragBlockViewGestureAction(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self.superview)
        if sender.state == .began {
            panGestureOriginX = point.x
            targetViewW = targetView.bounds.width
            viewW = self.bounds.width
            originalSelectedDurtaion = targetView.model.source.selectedTimeRange.duration
            originalGlobalStartTime = targetView.model.globalStartTime
            originalSelectedStartTime = targetView.model.source.selectedTimeRange.start
        } else if sender.state == .changed {
            let offset = point.x - panGestureOriginX
            if (offset + 10) > targetViewW {
                return
            }
            if offset >= 0 {
                if targetView.model.recomputeSelectedDurationOf(originalDuration: originalSelectedDurtaion, offset: -offset) == false {
                    return
                }
                targetView.model.recomputeGlobalStartTimeOf(originalTime: originalGlobalStartTime, offset: offset)
                targetView.model.recomputeSelectedStartTimeOf(originalTime: originalSelectedStartTime, offset: offset)
                self.delegate?.renderTrackDragView(self, targetView: targetView, leftBorderDragWith: offset, finalWidth: targetViewW - offset)
            } else {
                if targetView.model.recomputeSelectedDurationOf(originalDuration: originalSelectedDurtaion, offset: abs(offset)) == false {
                    return
                }
                targetView.model.recomputeGlobalStartTimeOf(originalTime: originalGlobalStartTime, offset: -abs(offset))
                targetView.model.recomputeSelectedStartTimeOf(originalTime: originalSelectedStartTime, offset: -abs(offset))
                self.delegate?.renderTrackDragView(self, targetView: targetView, leftBorderDragWith: offset, finalWidth: targetViewW + abs(offset))
            }
        } else if sender.state == .ended {
            self.delegate?.renderTrackDragViewIsDragEnd()
        }
    }

    @objc func rightDragBlockViewGestureAction(sender: UIPanGestureRecognizer) -> Void {
        let point = sender.location(in: self.superview)
        if sender.state == .began {
            panGestureOriginX = point.x
            targetViewW = targetView.bounds.width
            viewW = self.bounds.width
            originalSelectedDurtaion = targetView.model.source.selectedTimeRange.duration
        } else if sender.state == .changed {
            let offset = point.x - panGestureOriginX
            if abs(offset) > (targetViewW - 10) {
                return
            }
            if targetView.model.recomputeSelectedDurationOf(originalDuration: originalSelectedDurtaion, offset: offset) == false {
                return
            }
            self.delegate?.renderTrackDragView(self, targetView: targetView, rightBorderDragWith: offset, finalWidth: targetViewW + offset)
        } else if sender.state == .ended {
            self.delegate?.renderTrackDragViewIsDragEnd()
        }
    }

    func addDragBlockRoundCornerLayer(isLeft: Bool) {
        let path = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: 24, height: targetView.frame.size.height), byRoundingCorners: isLeft ? [UIRectCorner.bottomLeft, UIRectCorner.topLeft] : [UIRectCorner.topRight, UIRectCorner.bottomRight], cornerRadii: CGSize.init(width: 10, height: 10))
        let layer = CAShapeLayer.init()
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        if isLeft {
            leftDragBlockView.layer.addSublayer(layer)
        } else {
            rightDragBlockView.layer.addSublayer(layer)
        }
    }

    func addDragBlockArrowLayer(isLeft: Bool) {
        let weight = CGFloat.init(24)
        let height = targetView.frame.size.height
        let point0 = CGPoint.init(x: isLeft ? weight/3*2 : weight/3, y: height/3)
        let point1 = CGPoint.init(x: isLeft ? weight/3 : weight/3*2, y: height/3/2+height/3)
        let point2 = CGPoint.init(x: isLeft ? weight/3*2 : weight/3, y: height/3*2)
        let path = UIBezierPath.init()
        path.move(to: point0)
        path.addLine(to: point1)
        path.addLine(to: point2)
        path.close()
        let layer = CAShapeLayer.init()
        layer.path = path.cgPath
        layer.fillColor = UIColor.gray.cgColor
        if isLeft {
            leftDragBlockView.layer.addSublayer(layer)
        } else {
            rightDragBlockView.layer.addSublayer(layer)
        }
    }
}
