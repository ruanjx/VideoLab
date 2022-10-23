//
//  VLEExportViewController.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/22.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import Photos
import PKHUD

class VLEExportViewController: UIViewController {

    var exportSession: AVAssetExportSession?
    lazy var saveView = makeSaveView()
    lazy var shareView = makeShareView()
    lazy var navigatorView = makeNavigatorView()
    lazy var configResolutionView = makeConfigResolutionView()
    lazy var configFrameDurationView = makeConfigFrameDurationView()
    
    override func viewDidLoad() {
        setupView()
        handleSubviewClickEvent()
    }

    func setupView() {
        self.view.backgroundColor = UIColor.init(hexString: "#212123")
        self.view.addSubview(navigatorView)
        navigatorView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
        let backScrollView = UIScrollView.init()
        backScrollView.showsVerticalScrollIndicator = true
        backScrollView.showsHorizontalScrollIndicator = true
        backScrollView.isScrollEnabled = true
        self.view.addSubview(backScrollView)
        backScrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigatorView.snp.bottom)
        }
        backScrollView.addSubview(saveView)
        saveView.snp.makeConstraints { make in
            make.top.width.left.equalToSuperview()
            make.height.equalTo(100)
        }
        backScrollView.addSubview(configResolutionView)
        configResolutionView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(saveView.snp.bottom)
            make.height.equalTo(166)
        }
        backScrollView.addSubview(configFrameDurationView)
        configFrameDurationView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(configResolutionView.snp.bottom)
            make.height.equalTo(165)
        }
        backScrollView.addSubview(shareView)
        shareView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(configFrameDurationView.snp.bottom)
            make.height.equalTo(109)
        }
        shareView.isHidden = true
        let height = 100 + 166 + 165 + 109
        backScrollView.contentSize = CGSize.init(width: self.view.bounds.width, height: CGFloat(height))
    }

    func handleSubviewClickEvent() {
        navigatorView.clickCloseButtonBlock = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }
}

extension VLEExportViewController: VLEExportSaveViewDelegate {
    func exportSaveViewClickSaveButton(_ button: UIButton) {
        self.requestLibraryAuthorization { [weak self] (_) in
            guard let self = self else { return }
            self.exportVideo()
        }
    }
}

extension VLEExportViewController {

    func exportVideo() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let outputURL = documentDirectory.appendingPathComponent("demo.mp4")
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
            }
        }

        if let videoLab = VLEMainConcreteMediator.shared.buildCurrentTimeLineItemToExport() {
            HUD.show(.label("正在导出至本地，请稍后！"))
            self.exportSession = videoLab.makeExportSession(presetName: AVAssetExportPresetHighestQuality, outputURL: outputURL)
            self.exportSession?.exportAsynchronously(completionHandler: {
                switch self.exportSession?.status {
                case .completed:
                    self.saveFileToAlbum(outputURL)
                    DispatchQueue.main.async {
                        HUD.hide()
                        HUD.show(.label("导出成功!"))
                        HUD.hide(animated: true) { _ in
                            self.dismiss(animated: true)
                        }
                    }
                case .failed, .cancelled:
                    DispatchQueue.main.async {
                        HUD.hide()
                        HUD.show(.label("导出失败!"))
                        HUD.hide()
                    }
                default:
                    print("export")
                }
            })
        }
    }

    func requestLibraryAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            handler(status)
        } else {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    handler(status)
                }
            }
        }
    }

    func saveFileToAlbum(_ fileURL: URL, handler: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { (saved, error) in
            if let handler = handler {
                handler(saved, error)
            }
        }
    }
}

extension VLEExportViewController {
    private func makeNavigatorView() -> VLEExportNavigatorView {
        let view = VLEExportNavigatorView.init()
        return view
    }

    private func makeShareView() -> VLEExportShareView {
        let view = VLEExportShareView.init()
        return view
    }
    
    private func makeConfigResolutionView() -> VLEExportConfigResolutionView {
        let view = VLEExportConfigResolutionView.init()
        return view
    }
    
    private func makeConfigFrameDurationView() -> VLEExportConfigFrameDurationView {
        let view = VLEExportConfigFrameDurationView.init()
        return view
    }
    
    private func makeSaveView() -> VLEExportSaveView {
        let view = VLEExportSaveView.init(delegate: self)
        return view
    }
}
