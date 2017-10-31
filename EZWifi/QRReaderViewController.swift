//
//  QRCodeReaderViewController.swift
//  EZWifi
//
//  Created by nathan on 10/14/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftHTTP
import NetworkExtension
//import SwiftHTTP


class QRReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var scanView: UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("=====")
//
//        let text = "ssid" + "" + "password" + ""
//        print(text)
//
//        print("222")
//        let wifiHash = encryptWifi(text: text)
//
//        print("wifiHash \(wifiHash)")
//
//        print("222")
//
//        print("wifiHashLength \(wifiHash)")
//        print("222")
//        print(decryptWifi(text: wifiHash))
//
//        print("=====")
        
        // Get an instance of the AVCaptureDevice class to initialize a device object with media type as video.
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Set up scan zone, move the scanView and messageLabel to the front.
            scanView.layer.borderWidth = 10
            scanView.layer.borderColor = UIColor.red.cgColor
            view.bringSubview(toFront: scanView)
            view.bringSubview(toFront: messageLabel)
            
            // Setup QRCodeFrameView
            setupQRCodeFrameView()
            
            // Start video capture.
            captureSession?.startRunning()
        }
        catch {
            print(error)
            return
        }
    }
    
    // Prepare qrCodeFrameView for a new scan.
    func setupQRCodeFrameView() {
        
        // Remove previous rendered QRCodeFrameView.
        // Must be used from main thread only
        // Then initialize a new qrCodeFrameView for a new scan
        DispatchQueue.main.async() {
            self.qrCodeFrameView?.removeFromSuperview()
            
            self.qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = self.qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                self.view.addSubview(qrCodeFrameView)
                self.view.bringSubview(toFront: qrCodeFrameView)
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = ""
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let QRHash = metadataObj.stringValue {
                captureSession?.stopRunning()
                print("2222 \(QRHash)")
                registerWifi(hash: QRHash)
            }
        }
    }
    
    func registerWifi(hash: String) {
        let wifiText = decryptWifi(text: hash)
        
        let delimiters = "|||"
        
        if wifiText.contains(delimiters) == false {
            
            let alertController = UIAlertController(title: "Alert", message: "Invalid QRCode", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                self.resetCaptureSession()
            }))
            
            self.present(alertController, animated: true, completion: nil)

        } else {

            let wifiParams = wifiText.components(separatedBy: delimiters)
            let ssid = wifiParams[0], password = wifiParams[1]
            let WiFiConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
            
            WiFiConfig.joinOnce = false
            
            NEHotspotConfigurationManager.shared.apply(WiFiConfig) { error in
                print ("Error in NEHotspotConfigurationManager: \(error?.localizedDescription as Any)")
                self.resetCaptureSession()
            }
        }
    }
    
    func resetCaptureSession() {
        self.setupQRCodeFrameView()
        self.captureSession?.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
