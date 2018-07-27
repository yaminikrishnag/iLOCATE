//
//  QRCodeViewController.swift
//  iLocate
//
//  Created by Kaushik Reddy Awala on 10/31/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import AVFoundation

class QRCodeViewController: UIViewController {

    @IBOutlet weak var qrImage: UIImageView!
    @IBAction func qrCodeScanQRCodeButton(_ sender: UIButton) {
        performSegue(withIdentifier: "segueShowQRToScanQR", sender: self)
    }
    let originalBrightness = UIScreen.main.brightness
    //function to generate QRCode
    
    func generateQRCode(from string: String)->UIImage?{
        let data = string.data(using: String.Encoding.isoLatin1)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            filter.setValue(data, forKey: "inputMessage")
            
            guard let qrCodeImage = filter.outputImage else {
                return nil
            }
            
            let scaleX = qrImage.frame.size.width / qrCodeImage.extent.size.width
            let scaleY = qrImage.frame.size.height / qrCodeImage.extent.size.height
            
            let transform  = CGAffineTransform(scaleX: scaleX, y: scaleY)
            if let output = filter.outputImage?.transformed(by: transform){
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Add the scan QR code button here and perform segue on function call
//        let statsButton = UIBarButtonItem(title: "Stats", style: UIBarButtonItemStyle.done, target: self, action: #selector(scanQRCode))
//        self.navigationItem.rightBarButtonItem = statsButton
        
        //generate the QRCode and show it here
        if let myString = Auth.auth().currentUser?.uid //changed from email
        {

            let img = generateQRCode(from: myString)
            qrImage.image = img
        }
    }

//    @objc func scanQRCode(){
//        performSegue(withIdentifier: "segueShowQRToScanQR", sender: self)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIScreen.main.brightness = 1.0
    }
    override func viewDidDisappear(_ animated: Bool) {
        UIScreen.main.brightness = originalBrightness
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
