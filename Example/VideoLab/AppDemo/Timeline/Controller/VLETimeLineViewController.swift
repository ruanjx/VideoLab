//
//  VLETimeLineViewController.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/7/21.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit
import VideoLab
import CoreMedia
import PKHUD
import Photos

class VLETimeLineViewController: UIViewController {
    
    let stateModel = VLETimeLineStateModel.init()
    var dragSortView: VLETimeLineDragSortView?
    var renderLayerDargView: VLETimeLineRenderTrackDragView?
    var separateRenderTrackViewArray: [VLETimeLineSeparateRenderTrackView] = []
    
    lazy var scaleView = makeScaleView()
    lazy var toolBarView = makeToolBarView()
    lazy var backScrollView = makeBackScrollView()
    lazy var addAssetButton = makeAddAssetButton()
    lazy var renderTrackView = makeRenderTrackView()
    lazy var locationLineView = makeLocationLineView()
    lazy var movablyAddAssetButton = makeMovablyAddAssetButton()
    
    override func viewDidLoad() {
        setupView()
        addObserverFormNotification()
    }

    func addObserverFormNotification() {
        let name1 = Notification.Name.init(rawValue: VLEConstants.VLETimeLineAssetDidIsEmptyNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(assetDidIsEmpty), name: name1, object: nil)
        let name2 = Notification.Name.init(rawValue: VLEConstants.VLETimeLineAssetDidIsNonemptyNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(assetDidIsNonempty), name: name2, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func backScrollViewTapGestureAction(sender: UITapGestureRecognizer) {
        if renderLayerDargView != nil {
            renderLayerDargView?.removeFromSuperview()
            renderLayerDargView = nil
        } else {
            if let currentIndex = stateModel.currentSelectedIndex {
                let separateView = separateRenderTrackViewArray[currentIndex]
                separateView.hideSummaryView()
                renderTrackView.snp.updateConstraints { make in
                    make.top.equalTo(scaleView.snp.bottom).offset(62)
                }
                let height = separateView.bounds.height
                separateView.snp.updateConstraints { make in
                    make.height.equalTo(height-42)
                }
            }
        }
        stateModel.currentSelectedItemModel = nil
        stateModel.currentSelectedIndex = nil
        toolBarView.refreshClipButtonState(isShow: false)
    }

    @objc func assetDidIsEmpty() {
        if addAssetButton.isHidden == true {
            refreshViewState()
        }
    }

    @objc func assetDidIsNonempty() {
        if addAssetButton.isHidden == false {
            refreshViewState()
        }
    }

    public func addAssetToRenderTrackViewWith(itemModelArray: [VLETimeLineItemModel]) {
        guard !itemModelArray.isEmpty else {
            return
        }
        stateModel.renderTrackItemModelArray.append(contentsOf: itemModelArray)
        stateModel.refreshItemTime()
        reloadView()
        VLEMainConcreteMediator.shared.previewTimeLineItem(videoLab: buildVideolab())
    }

    public func addAudioToSeparateRenderLayerWith(source: Source) {
        HUD.show(.label("暂未开放"))
        HUD.hide(afterDelay: 0.5)
    }

    public func addStickerToSeparateRenderLayerWith(source: Source) {
        HUD.show(.label("暂未开放"))
        HUD.hide(afterDelay: 0.5)
    }

    public func buildVideolab() -> VideoLab {
        var renderLayers: [RenderLayer] = []
        for item in stateModel.renderTrackItemModelArray {
            renderLayers.append(item.renderLayer)
        }
        for item in stateModel.separateRenderTrackItemModelArray {
            renderLayers.append(item.renderLayer)
        }
        let composition = RenderComposition()
        composition.renderSize = stateModel.renderSize
        composition.layers = renderLayers
        return VideoLab.init(renderComposition: composition)
    }

    public func updatePlaybackProgress(time: CMTime) {
        if backScrollView.isTracking || backScrollView.isDecelerating {
            return
        }
        let second = CMTimeGetSeconds(time) * Float64(VLETimeLineConfig.framesPerSecond) * Float64(VLETimeLineConfig.ptPerFrames)
        backScrollView.setContentOffset(CGPoint.init(x: second, y: 0), animated: false)
    }
}

extension VLETimeLineViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking || scrollView.isDecelerating {
            let offsetX = scrollView.contentOffset.x
            let maxX = scrollView.contentSize.width - stateModel.fetchScaleFrontMargin() - stateModel.fetchScaleBackMargin()
            var rate = offsetX/maxX
            rate = (rate >= 1) ? 1 : rate
            rate = (rate <= 0) ? 0 : rate
            VLEMainConcreteMediator.shared.previewTimeLineItem(rate: Float64(rate))
        }

        if scrollView.contentOffset.x >=
            (renderTrackView.frame.size.width - stateModel.fetchScaleFrontMargin()) {
            let diff = scrollView.contentOffset.x - (renderTrackView.frame.size.width - stateModel.fetchScaleFrontMargin())
            if (diff/4 + 32) <= 50 {
                movablyAddAssetButton.snp.updateConstraints { make in
                    make.size.equalTo(CGSize.init(width: diff/4 + 32, height: diff/4 + 32))
                }
            }
            if diff > (50 + 12 + 12) {
                movablyAddAssetButton.snp.updateConstraints { make in
                    make.right.equalTo(self.view.snp.right).offset(-12 - (diff - 50 - 12 - 12))
                }
            }
        }
    }
}

extension VLETimeLineViewController: VLETimeLineDragSortViewDelegate {

    func timelineDargSortViewChangedSeparate(with selectedIndex: Int, dragPositionXRate: Float) {
        dragSortView?.removeFromSuperview()
        dragSortView = nil
        let startTime = stateModel.calculateSelectedTime(at: dragPositionXRate, sourceTime: stateModel.totalDuration)
        stateModel.renderTrackItemModelConvertToSeparate(at: selectedIndex, startTime: startTime)
        stateModel.refreshItemTime()
        let separateTrackView = createSeparateRenderTrackView(with: stateModel.separateRenderTrackItemModelArray.last!)
        separateRenderTrackViewArray.append(separateTrackView)
        reloadView()
        VLEMainConcreteMediator.shared.previewTimeLineItem(videoLab: buildVideolab())
    }

    func createSeparateRenderTrackView(with itemModel: VLETimeLineItemModel) -> VLETimeLineSeparateRenderTrackView {
        let separateTrackView = VLETimeLineSeparateRenderTrackView.init(with: itemModel, delegate: self)
        backScrollView.addSubview(separateTrackView)
        let offset = VLETimeLineConfig.convertToPt(value: itemModel.globalStartTime)
        let width = VLETimeLineConfig.convertToPt(value: itemModel.source.selectedTimeRange.duration)
        let dragblockW = separateTrackView.dragBlockWidth
        separateTrackView.snp.makeConstraints { make in
            make.top.equalTo(scaleView.snp.bottom).offset(0)
            make.height.equalTo(62)
            make.left.equalTo(backScrollView.snp.left).offset(offset - dragblockW + stateModel.fetchScaleFrontMargin())
            make.width.equalTo(width + dragblockW * 2)
        }
        return separateTrackView
    }

    func timeLineDargSortViewDeleteSegment(with selectedIndex: Int) {
        dragSortView?.removeFromSuperview()
        dragSortView = nil
        stateModel.renderTrackItemModelArray.remove(at: selectedIndex)
        stateModel.refreshItemTime()
        reloadView()
        VLEMainConcreteMediator.shared.previewTimeLineItem(videoLab: buildVideolab())
    }

    func timeLineDargSortViewDidSort(with selectedIndex: Int, targetIndex: Int) {
        dragSortView?.removeFromSuperview()
        dragSortView = nil
        guard selectedIndex != targetIndex else {
            return
        }
        self.stateModel.swapItemForRenderTrack(selectedIndex: selectedIndex, targetIndex: targetIndex)
        stateModel.refreshItemTime()
        reloadView()
        VLEMainConcreteMediator.shared.previewTimeLineItem(videoLab: buildVideolab())
    }
}

extension VLETimeLineViewController: VLETimeLineRenderTrackViewDelegate {
    func startDragSortRenderTrackSegmentView(with sender: UILongPressGestureRecognizer) {
        dragSortView?.beginSortView(with: sender)
    }

    func continuedDragSortRenderTrackSegmentView(with sender: UILongPressGestureRecognizer) {
        dragSortView!.moveSortView(with: sender)
    }

    func endDragSortRenderTrackSegmentView(with sender: UILongPressGestureRecognizer) {
        dragSortView?.endSortView(with: sender)
    }

    func showDragSortRenderTrackSegmentView(with selectedIndex: Int) {
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: VLEConstants.VLETImeLineShowDragSortViewNotification), object: nil)
        var imageArray: [UIImage] = []
        for item in self.stateModel.renderTrackItemModelArray {
            let image = item.thumbnailImageArray.first
            imageArray.append(image!)
        }
        if dragSortView != nil {
            dragSortView!.removeFromSuperview()
            dragSortView = nil
        } else {
            dragSortView = VLETimeLineDragSortView.init(with: imageArray, delegate: self, selectedIndex: selectedIndex)
            self.view.addSubview(dragSortView!)
            dragSortView!.snp.makeConstraints { make in
                make.width.top.centerX.equalToSuperview()
                make.height.equalTo(350)
            }
        }
    }

    func showRenderTrackDragView(with sourceView: VLETimeLineRenderTrackSegmentView, index: Int) {
        if let itemModel = stateModel.currentSelectedItemModel {
            if itemModel.isSeparateRenderTrack {
                let separateView = separateRenderTrackViewArray[stateModel.currentSelectedIndex!]
                separateView.hideSummaryView()
                renderTrackView.snp.updateConstraints { make in
                    make.top.equalTo(scaleView.snp.bottom).offset(62)
                }
                let height = separateView.bounds.height
                separateView.snp.updateConstraints { make in
                    make.height.equalTo(height-separateView.dragBlockHeight)
                }
            } else {
                renderLayerDargView?.removeFromSuperview()
                renderLayerDargView = nil
                stateModel.currentSelectedIndex = nil
                stateModel.currentSelectedItemModel = nil
            }
        }

        renderLayerDargView = VLETimeLineRenderTrackDragView.init(delegate: self, targetView: sourceView)
        backScrollView.addSubview(renderLayerDargView!)
        renderLayerDargView!.snp.makeConstraints { make in
            make.center.equalTo(sourceView)
            make.height.equalTo(sourceView.frame.height)
            make.width.equalTo(sourceView.frame.width + 24 + 24)
        }
        stateModel.currentSelectedItemModel = sourceView.model
        stateModel.currentSelectedIndex = index
        toolBarView.refreshClipButtonState(isShow: true)
    }
}

extension VLETimeLineViewController: VLETimeLineRenderTrackDragViewDelegate {

    func renderTrackDragView(_ dragView: VLETimeLineRenderTrackDragView, targetView: VLETimeLineRenderTrackSegmentView, leftBorderDragWith offsetX: CGFloat, finalWidth: CGFloat) {
        let scaleViewWidth = stateModel.fetchScaleViewWidth()
        self.renderTrackView.snp.updateConstraints { make in
            make.width.equalTo(scaleViewWidth)
        }
        targetView.snp.updateConstraints { make in
            make.width.equalTo(finalWidth)
        }
        dragView.snp.updateConstraints { make in
            make.width.equalTo(finalWidth + 24 + 24)
        }
        stateModel.refreshItemTime()
        reloadScaleView()
    }

    func renderTrackDragView(_ dragView: VLETimeLineRenderTrackDragView, targetView: VLETimeLineRenderTrackSegmentView, rightBorderDragWith offsetX: CGFloat, finalWidth: CGFloat) {
        let scaleViewWidth = stateModel.fetchScaleViewWidth()
        renderTrackView.snp.updateConstraints { make in
            make.width.equalTo(scaleViewWidth)
        }
        targetView.snp.updateConstraints { make in
            make.width.equalTo(finalWidth)
        }
        dragView.snp.updateConstraints { make in
            make.width.equalTo(finalWidth + 24 + 24)
        }
        stateModel.refreshItemTime()
        reloadScaleView()
    }

    func renderTrackDragViewIsDragEnd() {
        VLEMainConcreteMediator.shared.previewTimeLineItem(videoLab: buildVideolab())
    }
}

extension VLETimeLineViewController: VLETimeLineSeparateRenderTrackViewDelegate {

    func separateRenderTrackViewIsShowSummaryView(_ separateTrackView: VLETimeLineSeparateRenderTrackView) {
        renderTrackView.snp.updateConstraints { make in
            make.top.equalTo(scaleView.snp.bottom).offset(62 + separateTrackView.dragBlockHeight)
        }
        stateModel.currentSelectedIndex = separateRenderTrackViewArray.firstIndex(of: separateTrackView)
        stateModel.currentSelectedItemModel = stateModel.separateRenderTrackItemModelArray[stateModel.currentSelectedIndex!]
        for itemView in separateRenderTrackViewArray {
            if itemView != separateTrackView {
                itemView.hideSummaryView()
            }
        }
        renderLayerDargView?.removeFromSuperview()
        renderLayerDargView = nil
        toolBarView.refreshClipButtonState(isShow: true)
    }

    func separateRenderTrackView(_ view: VLETimeLineSeparateRenderTrackView, frameChangedWith width: CGFloat, xOffset: CGFloat) {
        view.snp.updateConstraints { make in
            make.left.equalTo(backScrollView.snp.left).offset(xOffset)
            make.width.equalTo(width)
        }
        stateModel.refreshItemTime()
        reloadScaleView()
    }

    func separateRenderTrackViewIsDragEnd() {
        VLEMainConcreteMediator.shared.previewTimeLineItem(videoLab: buildVideolab())
    }

    func separateRenderTrackViewNeedRemove(_ separateTrackView: VLETimeLineSeparateRenderTrackView) {
        renderTrackView.snp.updateConstraints { make in
            make.top.equalTo(scaleView.snp.bottom).offset(62)
        }
        stateModel.separateRenderTrackItemModelArray.remove(at: stateModel.currentSelectedIndex!)
        separateRenderTrackViewArray.remove(at: stateModel.currentSelectedIndex!)
        separateTrackView.removeFromSuperview()
        stateModel.currentSelectedItemModel = nil
        stateModel.currentSelectedIndex = nil
        toolBarView.refreshClipButtonState(isShow: false)
        stateModel.refreshItemTime()
        reloadView()
        VLEMainConcreteMediator.shared.previewTimeLineItem(videoLab: buildVideolab())
    }
}

extension VLETimeLineViewController: VLETimeLineToolBarViewDelegate {

    func clipRenderTrackView(at offsetX: CGFloat, itemModel: VLETimeLineItemModel) {
        let segmentView = renderTrackView.segmentViewArray[stateModel.currentSelectedIndex!]
        let originx = segmentView.frame.origin.x
        let segmentw = segmentView.bounds.width
        if (offsetX >= originx) && (offsetX < (originx + segmentw)) {
            let rate = Float((offsetX - originx) / segmentw)
            stateModel.clipRenderTrackItemModelAtCurrentIndex(clipRate: rate) { [weak self ] error in
                guard let self = self else {return}
                if error == nil {
                    self.renderTrackView.refreshSegmentViewWith(itemModelArray: self.stateModel.renderTrackItemModelArray)
                    self.renderTrackView.layoutIfNeeded()
                    self.showRenderTrackDragView(with: self.renderTrackView.segmentViewArray[self.stateModel.currentSelectedIndex!+1], index: self.stateModel.currentSelectedIndex!+1)
                }
            }
        } else {
            HUD.show(.label("选择位置错误！"))
            HUD.hide(afterDelay: 0.5)
        }
    }

    func clipSeparateRenderTrackView(at offsetX: CGFloat, itemModel: VLETimeLineItemModel) {
        let separateTrackView = separateRenderTrackViewArray[stateModel.currentSelectedIndex!]
        let viewX = separateTrackView.frame.origin.x + 24 - VLETimeLineConfig.frontMargin
        if offsetX > viewX {
            let selectedRate = Float((offsetX-viewX)/(separateTrackView.bounds.width-24-24))
            stateModel.clipSeparateRenderTrackItemModelAtCurrentIndex(clipRate: selectedRate) { [weak self] error, itemModel in
                guard let self = self else {return}
                if itemModel != nil {
                    let newSeparateTrackView = self.createSeparateRenderTrackView(with: itemModel!)
                    self.separateRenderTrackViewArray.insert(newSeparateTrackView, at: self.stateModel.currentSelectedIndex!+1)
                    separateTrackView.updateLayout()
                }
            }
        } else {
            HUD.show(.label("选择位置错误！"))
            HUD.hide(afterDelay: 0.5)
        }
    }

    func toolBarView(_ view: VLETimeLineToolBarView, clickCatButton button: UIButton) {
        guard let itemModel = stateModel.currentSelectedItemModel else {
            return
        }
        let xOffset = backScrollView.contentOffset.x
        if itemModel.isSeparateRenderTrack {
            clipSeparateRenderTrackView(at: xOffset, itemModel: itemModel)
        } else {
            clipRenderTrackView(at: xOffset, itemModel: itemModel)
        }
    }
}

extension VLETimeLineViewController {

    func setupView() {
        self.view.backgroundColor = UIColor.init(hexString: "#212123")
        self.view.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom)
        }
        self.view.addSubview(backScrollView)
        backScrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(toolBarView.snp.top).offset(0)
        }
        backScrollView.addSubview(scaleView)
        scaleView.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.width.equalTo(1)
            make.left.equalTo(backScrollView.snp.left).offset(self.stateModel.fetchScaleFrontMargin())
            make.top.equalToSuperview()
        }
        self.view.addSubview(addAssetButton)
        addAssetButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.center.equalToSuperview()
        }
        self.view.addSubview(locationLineView)
        locationLineView.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.snp.top).offset(14)
            make.bottom.equalTo(toolBarView.snp.top).offset(0)
        }
        backScrollView.addSubview(renderTrackView)
        renderTrackView.snp.makeConstraints { make in
            make.left.equalTo(backScrollView.snp.left).offset(stateModel.fetchScaleFrontMargin())
            make.top.equalTo(scaleView.snp.bottom).offset(62)
            make.height.equalTo(64)
            make.width.equalTo(1)
        }
        self.view.addSubview(movablyAddAssetButton)
        movablyAddAssetButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize.init(width: 32, height: 32))
            make.right.equalTo(self.view.snp.right).offset(-12)
            make.centerY.equalTo(renderTrackView)
        }
        refreshViewState()
    }

    func refreshViewState() {
        scaleView.isHidden = !stateModel.isHaveRenderTrack
        scaleView.isHidden = !stateModel.isHaveRenderTrack
        toolBarView.isHidden = !stateModel.isHaveRenderTrack
        addAssetButton.isHidden = stateModel.isHaveRenderTrack
        backScrollView.isHidden = !stateModel.isHaveRenderTrack
        renderTrackView.isHidden = !stateModel.isHaveRenderTrack
        locationLineView.isHidden = !stateModel.isHaveRenderTrack
        movablyAddAssetButton.isHidden = !stateModel.isHaveRenderTrack
    }

    func reloadView() {
        reloadScaleView()
        reloadRenderTrackView()
    }

    func reloadRenderTrackView() {
        var sum: CGFloat = 0
        for item in stateModel.renderTrackItemModelArray {
            sum += VLETimeLineConfig.convertToPt(value: item.source.selectedTimeRange.duration)
        }
        renderTrackView.snp.updateConstraints { make in
            make.width.equalTo(sum)
        }
        renderTrackView.refreshSegmentViewWith(itemModelArray: stateModel.renderTrackItemModelArray)
    }

    func reloadScaleView() {
        let scaleViewWidth = stateModel.fetchScaleViewWidth()
        let contentWidth = scaleViewWidth +
        stateModel.fetchScaleFrontMargin() +
        stateModel.fetchScaleBackMargin()
        scaleView.snp.updateConstraints { make in
            make.width.equalTo(scaleViewWidth)
        }
        scaleView.refreshTimeWith(seconds: stateModel.totalSeconds)
        backScrollView.contentSize = CGSize.init(width: contentWidth, height: 210)
    }

    @objc func addAssetButtonClickAction() {
        albumPermissions {
            VLEMainConcreteMediator.shared.addAssetWithPickerViewController()
        } denied: {
            HUD.show(.label("允许打开相册才能保存和编辑视频，请在设置->APP名称->照片中打开权限"))
            HUD.hide(afterDelay: 1)
        }
    }

    @objc func movablyAddAssetButtonClickAction() {
        albumPermissions {
            VLEMainConcreteMediator.shared.addAssetWithPickerViewController()
        } denied: {
            HUD.show(.label("允许打开相册才能保存和编辑视频，请在设置->APP名称->照片中打开权限"))
            HUD.hide(afterDelay: 1)
        }
    }

    func albumPermissions(success: @escaping () -> Void, denied: @escaping () -> Void) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (_: PHAuthorizationStatus) -> Void in
                self.albumPermissions(success: success, denied: denied)
            }
        } else if authStatus == .authorized {
            DispatchQueue.main.async {
                success()
            }
        } else {
            DispatchQueue.main.async {
                denied()
            }
        }
    }
}

extension VLETimeLineViewController {
    private func makeScaleView() -> VLETimeLineScaleView {
        let scaleView = VLETimeLineScaleView.init(model: stateModel)
        return scaleView
    }
    
    private func makeBackScrollView() -> UIScrollView {
        let scrollView = UIScrollView.init()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.indicatorStyle = UIScrollView.IndicatorStyle.white
        scrollView.delegate = self
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(backScrollViewTapGestureAction(sender:)))
        scrollView.addGestureRecognizer(tapGesture)
        return scrollView
    }
    
    private func makeAddAssetButton() -> UIButton {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "timeline_addresource_button"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(addAssetButtonClickAction), for: UIControl.Event.touchUpInside)
        return button
    }
    
    private func makeMovablyAddAssetButton() -> UIButton {
        let button = UIButton.init()
        button.setBackgroundImage(UIImage.init(named: "timeline_addresource_button"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(movablyAddAssetButtonClickAction), for: UIControl.Event.touchUpInside)
        return button
    }
    
    private func makeLocationLineView() -> UIView {
        let line = UIView.init()
        line.backgroundColor = UIColor.init(hexString: "#FF504E")
        return line
    }
    
    private func makeRenderTrackView() -> VLETimeLineRenderTrackView {
        let renderTrackView = VLETimeLineRenderTrackView.init(delegate: self)
        return renderTrackView
    }
    
    private func makeToolBarView() -> VLETimeLineToolBarView {
        let toolBarView = VLETimeLineToolBarView.init(delegate: self)
        return toolBarView
    }
}

