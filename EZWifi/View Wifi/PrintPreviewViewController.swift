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

class PrintPreviewViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    var image: UIImage!
    
    var printPDF: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.qrImageView.image = image
        generatePDF()
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
  
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(activityItems: [printPDF], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
