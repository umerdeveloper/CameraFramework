//
//  Camera.swift
//  CameraFramework
//
//  Created by Umer Khan on 04/04/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraDelegate {
    func stillImageCaptured(camera: Camera, image: UIImage)
}

class Camera: NSObject {
    
    var delegate: CameraDelegate?
    
    var controller: CameraViewController?
    var position: CameraPosition = .back {
        didSet {
            if session.isRunning {
                session.stopRunning()
                update()
            }
        }
    }
    
    required init(with controller: CameraViewController) {
        self.controller = controller
    }
    fileprivate var session = AVCaptureSession()
    fileprivate var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
    }
    var videoInput: AVCaptureDeviceInput?
    var videoOutput = AVCaptureVideoDataOutput()
    var photoOutput = AVCapturePhotoOutput()
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let controller = controller else { return nil }
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.bounds = controller.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return previewLayer
    }
    
    func captureStillImage() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func update() {
        recyleDeviceIO()
        guard let input = getNewInputDevice() else { return }
            
            guard session.canAddInput(input) else { return }
            guard session.canAddOutput(videoOutput) else { return }
            guard session.canAddOutput(photoOutput) else { return }
        
            videoInput = input
            session.addInput(input)
            session.addOutput(videoOutput)
            session.addOutput(photoOutput)
            session.commitConfiguration()
            session.startRunning()
    }

}
// MARK: - CaptureDevice Handling
private extension Camera {
    func getNewInputDevice() -> AVCaptureDeviceInput? {
        do {
            guard let device =  getDevice(with: self.position == .front ? AVCaptureDevice.Position.front: AVCaptureDevice.Position.back ) else { return nil }
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }
        catch { return nil }
    }
    
    func recyleDeviceIO() {
        for oldInput in session.inputs {
            session.removeInput(oldInput)
        }
        for oldOutput in session.outputs {
            session.removeOutput(oldOutput)
        }
    }
    
    private func getDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let discoverySession = discoverySession else { return nil }
        for device in discoverySession.devices {
            if device.position == position { return device }
        }
        return nil
    }
}
// MARK: - Still PhotoCapture Delegate
extension Camera: AVCapturePhotoCaptureDelegate {
    
     func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let image = photo.normalizedImage(forCameraPosition: position)
        if let delegate = delegate {
            delegate.stillImageCaptured(camera: self, image: image)
        }
    }
    
}
extension AVCapturePhoto {
    func normalizedImage(forCameraPosition position: CameraPosition) -> UIImage {
        guard let cgImage = self.cgImageRepresentation() else { return UIImage() }
        return UIImage(cgImage: cgImage.takeUnretainedValue(), scale: 1.0, orientation: getImageOrientation(forCamera: position))
    }
    private func getImageOrientation(forCamera: CameraPosition) -> UIImage.Orientation {
        switch UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
            case .landscapeLeft:
                return forCamera == .back ? .down: .upMirrored
            case .landscapeRight:
                return forCamera == .back ? .up: .downMirrored
            case .portraitUpsideDown:
                return forCamera == .back ? .left: .rightMirrored
            case .portrait:
                return forCamera == .back ? .right: .leftMirrored
            case .unknown:
                return forCamera == .back ? .right: .leftMirrored
            default:
                return forCamera == .back ? .right: .leftMirrored
        }
    }
}
