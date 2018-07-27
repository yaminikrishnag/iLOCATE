//
//  ScanQRCodeViewController.swift
//  iLocate
//
//  Created by Kaushik Reddy Awala on 11/2/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase
import AudioToolbox

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    @IBOutlet weak var QRCloseButton: UIButton!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBAction func readQRCloseButton(_ sender: UIButton) {
        performSegue(withIdentifier: "segueReadQRToTabbar", sender: self)
    }
    
    //varibale to store the uid of the qr code of the user
    var userUID: String = ""
    
    //add database reference
    var refUsers:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get the reference to the users node in firebase
        self.refUsers = Database.database().reference(withPath: "Users")
        // Do any additional setup after loading the view.
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        //bring the button and the sqaure box above the view layer to display on top of video
        self.view.bringSubview(toFront: qrCodeImageView)
        self.view.bringSubview(toFront: QRCloseButton)
        
        captureSession?.startRunning()
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
//        if metadataObjects.count == 0 {
//            qrCodeFrameView?.frame = CGRect.zero
//            userUID = "No QR code is detected"
//            return
//        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            //try to add this code snippet to stop scanning the qr code reading
            self.captureSession?.stopRunning()
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                userUID = metadataObj.stringValue!
                let addContactID: String = userUID
                let userToAddRef = refUsers.child(addContactID)
                //print("sssss")
                userToAddRef.observe(.value, with: { (snapshot) in
                    if let items = snapshot.value as? [String:AnyObject] {
                        //print("fullname: \(items["fullname"] as? String)")
                        self.addQRCodeDetailsToFirebaseDB(items: items)
                        
                        //give haptic feedback to the user that QR code reading was successful
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        sleep(1)
                        //Now, return to the contacts view controller
                        self.performSegue(withIdentifier: "segueReadQRToTabbar", sender: self)

                    } else {
                        print("QR Code invalid")
                        let alert = UIAlertController(title: "QR Code Invalid", message: "Please make sure the QR code you scan is from the user registered with iLocate app!", preferredStyle: UIAlertControllerStyle.alert)
                        let rescanAlertAction = UIAlertAction(title: "Rescan", style: UIAlertActionStyle.default, handler: {(action) in
                            //try to add this code snippet to start scanning the qr code reading
                            self.captureSession?.startRunning()
                        })
                        let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                            self.performSegue(withIdentifier: "segueReadQRToTabbar", sender: self)
                        })
                        alert.addAction(rescanAlertAction)
                        alert.addAction(cancelAlertAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        print(userUID)
    }
    
    //function to add details to the database
    func addQRCodeDetailsToFirebaseDB(items: [String:AnyObject]){
        let adddetails: [String:Any] = [
        "id" : items["id"] as! String,
        "fullname" : items["fullname"] as! String,
        "email" : items["email"] as! String,
        "phone" : items["phone"] as! String,
        "city" : items["city"] as! String,
        "profilePic": items["profilePic"] as! String
    ]
        //Now, get the reference to the current users key
        let currentUserRef = Database.database().reference(withPath: "Users")
        let curUserKeyRef = currentUserRef.child((Auth.auth().currentUser?.uid)!)
        let curUserContactRef = curUserKeyRef.child("contacts")
        let curUserContactKeyRef = curUserContactRef.child(userUID)
        curUserContactKeyRef.setValue(adddetails)
        print(adddetails["fullname"] as? String)
        print("Successfully added the contact to the database")
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
