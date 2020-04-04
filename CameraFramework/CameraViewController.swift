//
//  CameraViewController.swift
//  CameraFramework
//
//  Created by Umer Khan on 03/04/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit
import AVFoundation

public protocol CameraControllerDelegate {
    func cancelButtonTapped(controller: CameraViewController)
    func stillImageCaptured(controller: CameraViewController, image: UIImage)
}

public enum CameraPosition {
    case front
    case back
}

public final class CameraViewController: UIViewController {
    
    fileprivate var camera: Camera?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    public var delegate: CameraControllerDelegate?
    private var _shutterButton: UIButton?
    
    var shutterButton: UIButton {
        if let currentButton = _shutterButton {
            return currentButton
        }
        let button = UIButton()
        button.setImage(UIImage(named: "trigger", in: Bundle(for: CameraViewController.self), compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        _shutterButton = button
        return button
    }
    
    // create a button
    private var _cancelButton: UIButton?
    
    var cancelButton: UIButton {
        if let currentButton = _cancelButton {
            return currentButton
        }
        let button = UIButton(frame: CGRect(x: view.frame.minX + 10, y: view.frame.maxY - 50, width: 70, height: 30))
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        _cancelButton = button
        return button
    }
    
    public var position: CameraPosition = .back {
        didSet {
            guard let camera = camera else { return }
            camera.position = position
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let camera = camera else { return }
        createUI()
        camera.update()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateButtonFrames()
        updateUI(orientation: (UIApplication.shared.windows.first?.windowScene!.interfaceOrientation)!)
        
    }
    
    public class func getVersion() -> String? {
        let bundle = Bundle(for: CameraViewController.self)
        guard let info = bundle.infoDictionary else { return nil }
        guard let versionString = info["CFBundleShortVersionString"] as? String else { return nil }
        return versionString
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        let camera = Camera()
        camera.delegate = self
        self.camera = camera
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


fileprivate extension CameraViewController {
    func createUI() {
        guard let camera = camera else { return }
        guard let previewLayer = camera.getPreviewLayer() else { return }
        self.previewLayer = previewLayer
        view.layer.addSublayer(previewLayer)
        view.addSubview(cancelButton)
        view.addSubview(shutterButton)
    }
    
    func updateUI(orientation: UIInterfaceOrientation) {
        guard let previewLayer = previewLayer, let connection = previewLayer.connection else { return }
        previewLayer.frame = self.view.bounds
        previewLayer.frame = view.bounds
        switch orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            default:
                connection.videoOrientation = .portrait
        }
    }
    
    func updateButtonFrames() {
        cancelButton.frame = CGRect(x: view.frame.minX + 10, y: view.frame.maxY - 50, width: 70, height: 30)
        shutterButton.frame = CGRect(x: self.view.frame.midX - 35, y: self.view.frame.maxY - 80 , width: 70, height: 70)
    }
}
// MARK: - UI Button Functions
fileprivate extension CameraViewController {
    
    @objc func cancelButtonTapped() {
        if let delegate = delegate {
            delegate.cancelButtonTapped(controller: self)
        }
    }
    @objc func shutterButtonTapped() {
        if let camera = self.camera {
            camera.captureStillImage()
        }
    }
}
// MARK: - Camera Delegate
extension CameraViewController: CameraDelegate {
    func stillImageCaptured(camera: Camera, image: UIImage) {
        if let delegate = self.delegate {
            delegate.stillImageCaptured(controller: self, image: image)
        }
    }
}
