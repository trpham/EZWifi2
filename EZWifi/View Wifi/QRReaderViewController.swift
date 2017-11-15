//
//  QRCodeReaderViewController.swift
//  EZWifi
//
//  Created by nathan on 10/14/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit
import AVFoundation
import NetworkExtension
import SVProgressHUD
import JSSAlertView

//import StoreKit

class QRReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var priorScanOverlay: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var bottomOverlay: UIView!
    @IBOutlet weak var topOverLay: UIView!
    @IBOutlet weak var leftOverlay: UIView!
    @IBOutlet weak var rightOverlay: UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var blurView: UIView!
    
    @IBAction func startButtonTapped(_ sender: Any) {
        self.blurView.isHidden = true
        self.priorScanOverlay.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let logo = UIImage(named: "ezwifi-logo-main-page")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit // set imageview's content mode
        self.navigationItem.titleView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object with media type as video.
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)

        do {
            // Get an instance of the AVCaptureDeviceInput using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)

            // Initialize the captureSession object.
            captureSession = AVCaptureSession()

            captureSession?.addInput(input)

            // Add captureMetadataOutput here because we don't want the camera to capture any code prior to this button pressed.
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

            // Setup dark background overlay surround scanView
            self.topOverLay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.bottomOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.leftOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.rightOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.topOverLay.clipsToBounds = true
            self.bottomOverlay.clipsToBounds = true
            self.leftOverlay.clipsToBounds = true
            self.rightOverlay.clipsToBounds = true
            view.bringSubview(toFront: topOverLay)
            view.bringSubview(toFront: bottomOverlay)
            view.bringSubview(toFront: leftOverlay)
            view.bringSubview(toFront: rightOverlay)

            // Set up scan zone, move the scanView and messageLabel to the front.
            scanView.backgroundColor = .clear
            scanView.clipsToBounds = true
            scanView.translatesAutoresizingMaskIntoConstraints = false

            view.bringSubview(toFront: scanView)

            // Setup QRCodeFrameView
            setupQRCodeFrameView()

            // Start video capture.
            captureSession?.startRunning()

            let blur = UIBlurEffect(style: .regular)
            blurView = UIVisualEffectView(effect: blur)
            blurView.frame = self.view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(blurView)
            self.view.addSubview(self.priorScanOverlay)
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
            
            if self.qrCodeFrameView != nil {
                self.qrCodeFrameView?.removeFromSuperview()
            }
            
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
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let QRHash = metadataObj.stringValue {
                captureSession?.stopRunning()
                registerWifi(hash: QRHash)
            }
        }
    }
    
    func registerWifi(hash: String) {
        
        self.qrCodeFrameView?.removeFromSuperview()
        self.blurView.isHidden = false
        
        let wifiText = decryptWifi(text: hash)
        
        let delimiters = "|||"
        
        if wifiText.contains(delimiters) == false {
            let alertview = JSSAlertView().show(self,
                                                title: "Invalid QR",
                                                text: "Make sure you scan the correct QR Code.",
                                                buttonText: "OK",
                                                color: UIColorFromHex(0xCE0D31, alpha: 1))
            alertview.addAction(self.closeCallback)
            alertview.setTitleFont("NunitoSans-SemiBold")
            alertview.setTextFont("NunitoSans-Regular")
            alertview.setButtonFont("NunitoSans-SemiBold")
            alertview.setTextTheme(.light)
        } else {
            

            SVProgressHUD.show()
            SVProgressHUD.setRingThickness(10.0)

            let wifiParams = wifiText.components(separatedBy: delimiters)
            let ssid = wifiParams[0], password = wifiParams[1]
            
            
            let WiFiConfig = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
            
            WiFiConfig.joinOnce = false
            
            NEHotspotConfigurationManager.shared.apply(WiFiConfig) { error in
                
                DispatchQueue.global().async {
                    SVProgressHUD.dismiss()
                }
                
                if error != nil {
                    let alertview = JSSAlertView().show(self,
                                                        title: "Oops! Network Error",
                                                        text: error?.localizedDescription.capitalized,
                                                        buttonText: "OK",
                                                        color: UIColorFromHex(0xCE0D31, alpha: 1))
                    alertview.addAction(self.closeCallback)
                    alertview.setTitleFont("NunitoSans-SemiBold")
                    alertview.setTextFont("NunitoSans-Regular")
                    alertview.setButtonFont("NunitoSans-SemiBold")
                    alertview.setTextTheme(.light)
                } else {
                    let alertview = JSSAlertView().show(self,
                                                        title: "Success!",
                                                        text: "WiFi was succesfully connected.",
                                                        buttonText: "Done",
                                                        color: UIColorFromHex(0x31A343, alpha: 1))
                    alertview.addAction(self.successCallback)
                    alertview.setTitleFont("NunitoSans-SemiBold")
                    alertview.setTextFont("NunitoSans-Regular")
                    alertview.setButtonFont("NunitoSans-SemiBold")
                    alertview.setTextTheme(.light)
                }
            }
        }
    }
    
    func closeCallback() {
        self.resetCaptureSession()
        self.blurView.isHidden = false
        self.priorScanOverlay.isHidden = false
    }
    
    func successCallback() {
        self.resetCaptureSession()
        self.blurView.isHidden = false
        self.priorScanOverlay.isHidden = false
    }
    
    func resetCaptureSession() {
        self.setupQRCodeFrameView()
        self.captureSession?.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
