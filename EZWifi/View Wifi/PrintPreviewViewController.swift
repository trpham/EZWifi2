//
//  PrintPreviewViewController.swift
//  EZWifi
//
//  Created by nathan on 11/3/17.
//  Copyright © 2017 EZTeam. All rights reserved.
//

import UIKit
import WebKit
import PDFGenerator

class PrintPreviewViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    var image: UIImage!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var printPDF: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.qrImageView.image = image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func generatePDF() {
        
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("print.pdf"))
        do {
            let data = try PDFGenerator.generated(by: [self.printView])
            try data.write(to: dst, options: .atomic)
            self.printPDF = NSData(contentsOf:dst)
        } catch (let error) {
            print(error)
        }
    }
  
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindPreviewPageToWifiPage", sender: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        generatePDF()
        
//        self.printView.setNeedsDisplay()
        
        let activityViewController = UIActivityViewController(activityItems: [printPDF], applicationActivities: nil)
    
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
//        UINavigationBar.appearance().barTintColor = UIColor.black
        
        self.present(activityViewController, animated: true, completion: {
//             UINavigationBar.appearance().barTintColor = UIColor(0x007AFF)
            self.performSegue(withIdentifier: "unwindPreviewPageToWifiPage", sender: nil)
        })
    }
}
