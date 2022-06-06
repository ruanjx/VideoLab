//
//  PlayerViewController.swift
//  VideoLab
//
//  Created by Bear on 2020/8/27.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import AVKit
import Photos
import VideoLab

class VLEPlayerViewController: AVPlayerViewController {
    var videoLab: VideoLab
    var exportSession: AVAssetExportSession?
    
    init(videoLab: VideoLab) {
        self.videoLab = videoLab
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
    }

    // MARK: - Private
    
    func setupNavigationItem() {
        let barButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(saveAction))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func saveAction() {
        requestLibraryAuthorization { [weak self] (status) in
            guard let self = self else { return }
            self.exportVideo()
        }
    }
    
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
        
        exportSession = videoLab.makeExportSession(presetName: AVAssetExportPresetHighestQuality, outputURL: outputURL)
        exportSession?.exportAsynchronously(completionHandler: {
            switch self.exportSession?.status {
            case .completed:
                self.saveFileToAlbum(outputURL)
                print("export completed")
            case .failed:
                print("export failed")
            case .cancelled:
                print("export cancelled")
            default:
                print("export")
            }
        })
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
