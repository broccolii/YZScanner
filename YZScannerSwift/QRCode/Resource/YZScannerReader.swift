//
//  YZScannerReader.swift
//  QRCode
//
//  Created by Broccoli on 2017/2/16.
//  Copyright © 2017年 Broccoli. All rights reserved.
//

import UIKit
import AVFoundation

class YZScannerReader: NSObject {
    
    var defaultDevice: AVCaptureDevice!
    var defaultDeviceInput: AVCaptureDeviceInput!
    var metadataOutput: AVCaptureMetadataOutput!
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var completionBlock: ((_: String) -> Void)? = nil
    
    // MARK: - Creating and Inializing QRCode Readers
    override init() {
        super.init()
        self.setupAVComponents()
    }
    
    convenience override init() {
        return self.init()
    }
    
    func setupAVComponents() {
        self.defaultDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // input
        var error: Error?
        self.defaultDeviceInput = try? AVCaptureDeviceInput(device: self.defaultDevice)
        if error != nil {
            var e = NSException(name: "com.youzan.scannerReader.setupAVComponentsError", reason: "Initializing AVCaptureDeviceInput failed", userInfo: nil)
        }
        // output
        self.metadataOutput = AVCaptureMetadataOutput()
        self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.metadataOutput.metadataObjectTypes = self.metadataObjectTypes
        // session
        self.session = AVCaptureSession()
        self.session.sessionPreset = self.sessionPreset
        if self.session.canAddInput(self.defaultDeviceInput) && self.defaultDevice {
            self.session.addInput(self.defaultDeviceInput)
        }
        if self.session.canAddOutput(self.metadataOutput) {
            self.session.addOutput(self.metadataOutput)
        }
        if !self.metadataObjectTypes {
            self.metadataOutput.metadataObjectTypes = self.metadataOutput.availableMetadataObjectTypes()
        }
        else {
            var metadataObjectTypes = [Any]()
            for availableMetadataObject: String in self.metadataOutput.availableMetadataObjectTypes {
                if self.metadataObjectTypes.contains(availableMetadataObject) {
                    metadataObjectTypes.append(availableMetadataObject)
                }
            }
            self.metadataOutput.metadataObjectTypes = metadataObjectTypes
        }
        // preview
        self.previewLayer = AVCaptureVideoPreviewLayer.withSession(self.session)
        self.previewLayer.videoGravity = .resizeAspectFill
    }
    
    // MARK: - Controlling Reader
    
    func startScanning() {
        if !self.session.isRunning {
            self.session.startRunning()
        }
    }
    
    func stopScanning() {
        if self.session.isRunning {
            self.session.stopRunning()
        }
    }
    
    func isRunning() -> Bool {
        return self.session.isRunning()
    }
    // MARK: - Managing the Orientation
    
    class func videoOrientation(from interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch interfaceOrientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        default:
            return .portraitUpsideDown
        }
        
    }
    // MARK: - Managing the Block
    
    func didCaptureScannerResult(_ completionBlock: @escaping (_ resultAsString: String) -> Void) {
        self.completionBlock() = completionBlock
    }
    
    // MARK: - AVCaptureMetadataOutputObjects Delegate Methods
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutputMetadataObjects metadataObjects: [Any], from connection: AVCaptureConnection) {
        if metadataObjects != nil && metadataObjects.count > 0 {
            defer {
            }
            do {
                var obj: AVMetadataObject? = metadataObjects[0]
                if (obj? is AVMetadataMachineReadableCodeObject) {
                    //
                    self.stopScanning()
                    var scannedResult: String? = (obj as? AVMetadataMachineReadableCodeObject)?.stringValue
                    if self.completionBlock {
                        _completionBlock(scannedResult)
                    }
                }
            } catch let exception {
                self.startScanning()
            }
        }
    }
    // MARK: -
    
    override func sessionPreset() -> String {
        if !self.sessionPreset {
            self.sessionPreset = AVCaptureSessionPresetInputPriority
        }
        return self.sessionPreset
    }
    
    var sessionPreset: String = ""
    // MARK: - Checking the Metadata Items Types
    /**
     Supported code types
     */
    private(set) var metadataObjectTypes = [Any]()
    // MARK: - Viewing the Camera
    /**
     preview layer
     */
    private(set) var previewLayer: AVCaptureVideoPreviewLayer!
    // MARK: - status
    /**
     capture session status
     */
    private(set) var isRunning: Bool = false
    // MARK: - Controlling the Reader
    /**
     Starts scanning the codes
     */
    
    func startScanning() {
    }
    /**
     Stops scanning the codes
     */
    
    func stopScanning() {
    }
    // MARK: - Getting Inputs and Outputs
    /**
     input device
     */
    private(set) var defaultDeviceInput: AVCaptureDeviceInput!
    /**
     output device
     */
    private(set) var metadataOutput: AVCaptureMetadataOutput!
    // MARK: - Managing the Orientation
    
    class func videoOrientation(from interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
    }
    // MARK: - Managing the Block
    
    func didCaptureScannerResult(_ completionBlock: @escaping (_ resultAsString: String) -> Void) {
    }
}
