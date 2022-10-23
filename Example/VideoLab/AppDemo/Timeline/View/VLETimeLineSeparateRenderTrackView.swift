//
//  VLETimeLineSeparateRenderTrackView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/16.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import VideoLab
import CoreMedia

protocol VLETimeLineSeparateRenderTrackViewDelegate: NSObjectProtocol {
    func separateRenderTrackView(_ view: VLETimeLineSeparateRenderTrackView, frameChangedWith width: CGFloat, xOffset: CGFloat)
    func separateRenderTrackViewIsDragEnd()
    func separateRenderTrackViewIsShowSummaryView(_ separateTrackView: VLETimeLineSeparateRenderTrackView)
    func separateRenderTrackViewNeedRemove(_ separateTrackView: VLETimeLineSeparateRenderTrackView)
}

class VLETimeLineSeparateRenderTrackView: UIView {
    weak var delegate: VLETimeLineSeparateRenderTrackViewDelegate?
    let itemModel: VLETimeLineItemModel
    var summaryViewW: CGFloat = 0
    var panGestureOriginX: CGFloat = 0
    var leftDragBlockViewX: CGFloat = 0
    var viewWidth: CGFloat = 0
    var viewX: CGFloat = 0
    var originalSelectedDurtaion: CMTime = CMTime.zero
    var originalGlobalStartTime: CMTime = CMTime.zero
    var originalSelectedStartTime: CMTime = CMTime.zero
    let dragBlockWidth: CGFloat = 24
    let dragBlockHeight: CGFloat = 42

    lazy var iconView: UIImageView = {
        let view = UIImageView.init()
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(iconViewTapGestureAction(sender:)))
        view.addGestureRecognizer(gesture)
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var extentView: UIView = {
        let view = UIView.init()
        return view
    }()
    
    lazy var leftDragBlockView: UIView = {
        let view = UIView.init()
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(leftDragBlockViewPanGestureAction(sender:)))
        view.addGestureRecognizer(gesture)
        view.backgroundColor = UIColor.clear
        return view
    }()

    lazy var rightDragBlockView: UIView = {
        let view = UIView.init()
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(rightDragBlockViewPanGestureAction(sender:)))
        view.addGestureRecognizer(gesture)
        view.backgroundColor = UIColor.clear
        return view
    }()

    lazy var summaryView: UIView = {
        let view = UIView.init()
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(summaryViewTapGestureAction(sender:)))
        view.addGestureRecognizer(tapGesture)
        let longGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(summaryViewLongGestureAction(sender:)))
        view.addGestureRecognizer(longGesture)
        view.backgroundColor = UIColor.init(hexString: "#FFC432")
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3
        return view
    }()
    
    init(with itemModel: VLETimeLineItemModel, delegate: VLETimeLineSeparateRenderTrackViewDelegate) {
        self.delegate = delegate
        self.itemModel = itemModel
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }

    func setupView() {
        let width = VLETimeLineConfig.convertToPt(value: itemModel.source.selectedTimeRange.duration)
        self.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 34, height: 40))
            make.top.equalToSuperview()
            make.left.equalTo(self.snp.left).offset(7)
        }
        self.addSubview(extentView)
        extentView.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(4)
            make.left.equalTo(self.snp.left).offset(dragBlockWidth)
            make.width.equalTo(width)
            make.height.equalTo(12)
        }
        self.addSubview(leftDragBlockView)
        leftDragBlockView.snp.makeConstraints { make in
            make.top.equalTo(self.extentView.snp.bottom).offset(0)
            make.left.equalTo(self.snp.left).offset(0)
            make.size.equalTo(CGSize.init(width: dragBlockWidth, height: dragBlockHeight))
        }
        self.addSubview(summaryView)
        summaryView.snp.makeConstraints { make in
            make.left.equalTo(leftDragBlockView.snp.right).offset(0)
            make.height.equalTo(dragBlockHeight)
            make.top.equalTo(leftDragBlockView)
            make.width.equalTo(width)
        }
        self.addSubview(rightDragBlockView)
        rightDragBlockView.snp.makeConstraints { make in
            make.left.equalTo(summaryView.snp.right).offset(0)
            make.top.equalTo(leftDragBlockView)
            make.size.equalTo(CGSize.init(width: dragBlockWidth, height: dragBlockHeight))
        }
        summaryView.isHidden = true
        leftDragBlockView.isHidden = true
        rightDragBlockView.isHidden = true
        self.layoutIfNeeded()
        addIconLayer()
        addExtentLayer()
        addDragBlockRoundCornerLayer(isLeft: true)
        addDragBlockRoundCornerLayer(isLeft: false)
        addDragBlockArrowLayer(isLeft: true)
        addDragBlockArrowLayer(isLeft: false)
    }
    
    @objc func iconViewTapGestureAction(sender: UITapGestureRecognizer) {
        if summaryView.isHidden == false {
            return
        }
        showSummaryView()
    }
    
    func showSummaryView() {
        summaryView.isHidden = false
        rightDragBlockView.isHidden = false
        leftDragBlockView.isHidden = false
        let height = self.bounds.height
        self.snp.updateConstraints { make in
            make.height.equalTo(height + dragBlockHeight)
        }
        self.delegate?.separateRenderTrackViewIsShowSummaryView(self)
    }
    
    func hideSummaryView() {
        if summaryView.isHidden == false {
            let height = self.bounds.height
            self.snp.updateConstraints { make in
                make.height.equalTo(height - dragBlockHeight)
            }
        }
        summaryView.isHidden = true
        rightDragBlockView.isHidden = true
        leftDragBlockView.isHidden = true
    }

    func updateLayout() {
        let summaryW = VLETimeLineConfig.convertToPt(value: itemModel.source.selectedTimeRange.duration)
        self.snp.updateConstraints { make in
            make.width.equalTo(summaryW + dragBlockWidth * 2)
        }
        summaryView.snp.updateConstraints { make in
            make.width.equalTo(summaryW)
        }
    }

    @objc func rightDragBlockViewPanGestureAction(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self.superview)
        if sender.state == .began {
            panGestureOriginX = point.x
            summaryViewW = summaryView.frame.size.width
            viewWidth = self.frame.size.width
            viewX = self.frame.origin.x
            originalSelectedDurtaion = itemModel.source.selectedTimeRange.duration
        } else if sender.state == .changed {
            let offset = point.x - panGestureOriginX
            if abs(offset) >= (summaryViewW - 10) {
                return
            }
            if itemModel.recomputeSelectedDurationOf(originalDuration: originalSelectedDurtaion, offset: offset) == false {
                return
            }
            summaryView.snp.updateConstraints { make in
                make.width.equalTo(summaryViewW+offset)
            }
            extentView.snp.updateConstraints { make in
                make.width.equalTo(summaryViewW+offset)
            }
            self.delegate?.separateRenderTrackView(self, frameChangedWith: viewWidth+offset, xOffset: viewX)
        } else if sender.state == .ended {
            self.delegate?.separateRenderTrackViewIsDragEnd()
            extentView.layer.sublayers = nil
            addExtentLayer()
        }
    }

    @objc func leftDragBlockViewPanGestureAction(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self.superview)
        if sender.state == .began {
            panGestureOriginX = point.x
            summaryViewW = self.summaryView.frame.size.width
            leftDragBlockViewX = self.leftDragBlockView.frame.origin.x
            viewWidth = self.frame.size.width
            viewX = self.frame.origin.x
            originalSelectedDurtaion = itemModel.source.selectedTimeRange.duration
            originalGlobalStartTime = itemModel.globalStartTime
            originalSelectedStartTime = itemModel.source.selectedTimeRange.start
        } else if sender.state == .changed {
            let offset = point.x - panGestureOriginX
            let xOffset = offset >= 0 ? (viewX+offset) : (viewX-abs(offset))
            if (xOffset + dragBlockWidth) < VLETimeLineConfig.frontMargin {
                return
            }
            if (offset + 10) > summaryViewW {
                return
            }
            if offset >= 0 {
                if itemModel.recomputeSelectedDurationOf(originalDuration: originalSelectedDurtaion, offset: -offset) == false {
                    return
                }
                itemModel.recomputeGlobalStartTimeOf(originalTime: self.originalGlobalStartTime, offset: offset)
                itemModel.recomputeSelectedStartTimeOf(originalTime: self.originalSelectedStartTime, offset: offset)
                self.delegate?.separateRenderTrackView(self, frameChangedWith: self.viewWidth-offset, xOffset: xOffset)
                summaryView.snp.updateConstraints { make in
                    make.width.equalTo(summaryViewW-offset)
                }
                extentView.snp.updateConstraints { make in
                    make.width.equalTo(summaryViewW-offset)
                }
            } else {
                if itemModel.recomputeSelectedDurationOf(originalDuration: originalSelectedDurtaion, offset: abs(offset)) == false {
                    return
                }
                itemModel.recomputeGlobalStartTimeOf(originalTime: originalGlobalStartTime, offset: -abs(offset))
                itemModel.recomputeSelectedStartTimeOf(originalTime: originalSelectedStartTime, offset: -abs(offset))
                self.delegate?.separateRenderTrackView(self, frameChangedWith: viewWidth+abs(offset), xOffset: xOffset)
                summaryView.snp.updateConstraints { make in
                    make.width.equalTo(summaryViewW+abs(offset))
                }
                extentView.snp.updateConstraints { make in
                    make.width.equalTo(summaryViewW+abs(offset))
                }
            }
        } else if sender.state == .ended {
            self.delegate?.separateRenderTrackViewIsDragEnd()
            extentView.layer.sublayers = nil
            addExtentLayer()
        }
    }

    @objc func summaryViewTapGestureAction(sender: UITapGestureRecognizer) {
        let controller = VLEMainConcreteMediator.shared.mainViewController
        let alert = UIAlertController(title: nil, message: "是否删除当前图层？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.delegate?.separateRenderTrackViewNeedRemove(self)
        }))
        controller!.present(alert, animated: true)
    }

    @objc func summaryViewLongGestureAction(sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: self.superview)
        if sender.state == .began {
            panGestureOriginX = point.x
            viewWidth = self.frame.size.width
            viewX = self.frame.origin.x
            originalGlobalStartTime = itemModel.globalStartTime
        } else if sender.state == .changed {
            let offset = point.x - panGestureOriginX
            let xOffset = viewX + offset
            if (xOffset + dragBlockWidth) < VLETimeLineConfig.frontMargin {
                return
            }
            itemModel.recomputeGlobalStartTimeOf(originalTime: originalGlobalStartTime, offset: offset)
            self.delegate?.separateRenderTrackView(self, frameChangedWith: viewWidth, xOffset: viewX + offset)
        } else if sender.state == .ended {
            self.delegate?.separateRenderTrackViewIsDragEnd()
        }
    }
}

extension VLETimeLineSeparateRenderTrackView {

    func addDragBlockRoundCornerLayer(isLeft: Bool) {
        let path = UIBezierPath.init(roundedRect: leftDragBlockView.bounds, byRoundingCorners: isLeft ? [UIRectCorner.bottomLeft, UIRectCorner.topLeft] : [UIRectCorner.topRight, UIRectCorner.bottomRight], cornerRadii: CGSize.init(width: 10, height: 10))
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
        let width = leftDragBlockView.frame.size.width
        let height = leftDragBlockView.frame.size.height
        let point0 = CGPoint.init(x: isLeft ? width/3*2 : width/3, y: height/3)
        let point1 = CGPoint.init(x: isLeft ? width/3 : width/3*2, y: height/3/2+height/3)
        let point2 = CGPoint.init(x: isLeft ? width/3*2 : width/3, y: height/3*2)

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

    func addExtentLayer() {
        let rect = CGRect.init(x: 0, y: 0, width: extentView.bounds.width, height: extentView.bounds.height)
        let rect1 = CGRect.init(x: 0, y: 0, width: extentView.bounds.width, height: extentView.bounds.height/5)
        let size = CGSize.init(width: 3, height: 3)
        let path4 = UIBezierPath.init(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: size)
        path4.lineCapStyle = .round
        path4.lineJoinStyle = .round
        let path5 = UIBezierPath.init(roundedRect: rect1, cornerRadius: 0)
        path5.lineCapStyle = .round
        path5.lineJoinStyle = .round
        let layer5 = CAShapeLayer.init()
        layer5.fillColor = UIColor.init(hexString: "#212123")!.cgColor
        layer5.strokeColor = UIColor.init(hexString: "#212123")!.cgColor
        layer5.lineWidth = 2
        layer5.path = path5.cgPath
        let layer4 = CAShapeLayer.init()
        layer4.fillColor = UIColor.clear.cgColor
        layer4.strokeColor = UIColor.init(hexString: "#BABABA")?.cgColor
        layer4.lineWidth = 2
        layer4.path = path4.cgPath

        extentView.layer.addSublayer(layer4)
        extentView.layer.addSublayer(layer5)
    }

    func addIconLayer() {
        let arcCenterPoint: CGPoint = CGPoint.init(x: iconView.bounds.width/2, y: iconView.bounds.width/2)
        let arcRadius: CGFloat = 15
        let arcBottomPoint: CGPoint = CGPoint.init(x: arcCenterPoint.x, y: iconView.frame.origin.y + iconView.bounds.height)
        let leftPoint: CGPoint = CGPoint.init(x: arcCenterPoint.x-arcRadius, y: arcCenterPoint.y)
        let rightPoint: CGPoint = CGPoint.init(x: arcCenterPoint.x+arcRadius, y: arcCenterPoint.y)
        let leftControlPoint: CGPoint = CGPoint.init(x: leftPoint.x, y: arcBottomPoint.y/4*3)
        let rightControlPoint: CGPoint = CGPoint.init(x: rightPoint.x, y: arcBottomPoint.y/4*3)
        let path1 = UIBezierPath.init(arcCenter: arcCenterPoint, radius: arcRadius, startAngle: .pi, endAngle: 0, clockwise: true)
        path1.lineCapStyle = .round
        path1.lineJoinStyle = .round
        path1.move(to: leftPoint)
        path1.addQuadCurve(to: arcBottomPoint, controlPoint: leftControlPoint)
        path1.addQuadCurve(to: rightPoint, controlPoint: rightControlPoint)

        let masklayer = CAShapeLayer.init()
        masklayer.path = path1.cgPath
        let borderLayer = CAShapeLayer.init()
        borderLayer.path = path1.cgPath
        borderLayer.strokeColor = UIColor.init(hexString: "#BABABA")?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 4

        iconView.image = itemModel.thumbnailImageArray.first
        iconView.layer.mask = masklayer
        iconView.layer.addSublayer(borderLayer)
    }
}
