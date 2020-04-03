//
//  CameraViewController.swift
//  CameraFramework
//
//  Created by Umer Khan on 03/04/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit
import AVFoundation

public final class CameraViewController: UIViewController {
    var captureSession = AVCaptureSession()
    var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
    }
    var videoCapture = AVCaptureVideoDataOutput()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        createUI()
        commitConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        return previewLayer
    }
    
    func getDevice() -> AVCaptureDevice? {
        guard let discoverySession = discoverySession else { return nil }
        for device in discoverySession.devices {
            if device.position == AVCaptureDevice.Position.back {
                return device
            }
        }
        return nil
    }
    
    func createUI() {
        view.layer.addSublayer(getPreviewLayer(session: captureSession))
    }
    
    func commitConfiguration() {
        do {
            guard let device = getDevice() else { return }
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) && captureSession.canAddOutput(videoCapture) {
                captureSession.addInput(input)
                captureSession.addOutput(videoCapture)
                captureSession.commitConfiguration()
                captureSession.startRunning()
            }
            
            
        } catch {
            print("Error linking device to AVInputs!")
            return
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}
