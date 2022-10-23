//
//  VLETimeLineDragSortGridView.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/21.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class VLETimeLineDragSortGridView: UIView, UIGestureRecognizerDelegate{
    
    var itemWidth: CGFloat
    var itemHeight: CGFloat
    var edgeInsets: UIEdgeInsets
    var startPoint: CGPoint?
    var startCenter: CGPoint?
    var tempAlpha: CGFloat?
    var touchBeginPoint: CGPoint?
    var dragView: VLETimeLineDragSortMoveItemView?
    var subItemViews: [VLETimeLineDragSortMoveItemView]
    var updateSortedBlock: (([VLETimeLineDragSortMoveItemView]) -> Void)?

    lazy var dragImageView: UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()

    init(subViews: [VLETimeLineDragSortMoveItemView],
         itemWidth: CGFloat,
         itemHeight: CGFloat,
         edgeInsets: UIEdgeInsets) {
        self.subItemViews = subViews
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.edgeInsets = edgeInsets
        super.init(frame: CGRect.zero)
        for item in self.subItemViews {
            self.addSubview(item)
        }

        refreshSubItemViewPosition()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    func refreshSubItemViewPosition() {
        for itemView in subItemViews {
            itemView.snp.removeConstraints()
        }

        var index: CGFloat = 0
        for itemView in subItemViews {
            itemView.snp.makeConstraints { make in
                make.size.equalTo(CGSize.init(width: itemWidth, height: itemHeight))
                make.top.equalTo(self.snp.top).offset(edgeInsets.top)
                make.left.equalTo(self.snp.left).offset(edgeInsets.left + index * (itemWidth + edgeInsets.left))
            }
            index += 1
        }

        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }

    func selectedItemView(with index: Int) {
        let view = subItemViews[index]
        let center = CGPoint.init(x: view.bounds.width/2 + view.frame.origin.x, y: view.bounds.height/2 + view.frame.origin.y)
        touchBeginPoint = center
        dragView = view
    }

    func beginDragItemView(with sender: UILongPressGestureRecognizer) {
        longPressDragGestureBegin(point: touchBeginPoint!)
    }

    func moveDragItemView(with sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: self)
        longPressDragGestureMove(point: point)
    }

    func endDragItemView(with sender: UILongPressGestureRecognizer) {
        if !__CGPointEqualToPoint(touchBeginPoint!, CGPoint.zero) {
            longPressDragGestureEnd()
        }
    }
}

extension VLETimeLineDragSortGridView {

    func longPressDragGestureRecongnize(point: CGPoint) -> Bool {

        for itemView in subItemViews {
            if itemView.longPressDragDisable == false {
                let rect = self.convert(itemView.frame, from: itemView.superview)
                if rect.contains(point) {
                    dragView = itemView
                    break
                }
            }
        }

        if dragView == nil {
            return false
        } else {
            return true
        }
    }

    func longPressDragGestureBegin(point: CGPoint) {

        guard self.dragView != nil else {
            return
        }

        let rect = self.convert(dragView!.frame, from: dragView!.superview)
        dragImageView.frame = rect
        dragImageView.image = dragView?.backImageView.image
        dragImageView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        self.addSubview(dragImageView)
        startPoint = point
        startCenter = dragImageView.center
        tempAlpha = dragView!.alpha
        dragView!.alpha = 0
    }

    func longPressDragGestureMove(point: CGPoint) {
        let offset = CGPoint.init(x: point.x - startPoint!.x, y: point.y-startPoint!.y)
        dragImageView.center = CGPoint.init(x: startPoint!.x + offset.x, y: startPoint!.y + offset.y)

        var targetView: VLETimeLineDragSortMoveItemView?
        for itemView in subItemViews {
            if itemView.alpha>0 && (itemView.longPressDragDisable == false) {
                let rect = self.convert(itemView.frame, from: itemView.superview)
                if rect.contains(point) {
                    targetView = itemView
                    break
                }
            }
        }

        if targetView != nil {
            let targetIndex = subItemViews.firstIndex(of: targetView!)
            subItemViews.remove(at: subItemViews.firstIndex(of: dragView!)!)
            subItemViews.insert(dragView!, at: targetIndex!)
            refreshSubItemViewPosition()
            self.bringSubviewToFront(dragImageView)
            updateSortedBlock?(subItemViews)
        }
    }

    func longPressDragGestureEnd() {
        UIView.animate(withDuration: 0.2) {
            self.dragImageView.transform = CGAffineTransform.identity
            self.dragImageView.frame = self.dragView!.frame
        } completion: { _ in
            self.dragView?.alpha = self.tempAlpha!
            self.dragImageView.removeFromSuperview()
        }
    }

    func snapshotWith(view: UIView) -> UIImage? {
        let scale = view.window!.screen.scale
        let size = view.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension VLETimeLineDragSortGridView {

    @objc func longPressGestureAction(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            longPressDragGestureBegin(point: touchBeginPoint!)
        case .changed:
            let point = sender.location(in: self)
            longPressDragGestureMove(point: point)
        case .ended, .cancelled, .failed:
            if !__CGPointEqualToPoint(touchBeginPoint!, CGPoint.zero) {
                longPressDragGestureEnd()
            }
        default:
            print("")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.randomElement()
        let point = touch?.location(in: self)
        touchBeginPoint = point!

        if ((longPressDragGestureRecongnize(point: touchBeginPoint!)) == true) {
            super.touchesBegan(touches, with: event)
        }
    }
}
