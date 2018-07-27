//
//  ReadQRCodeViewController.swift
//  iLocate
//
//  Created by Kaushik Reddy Awala on 10/31/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import AVFoundation

class ReadQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //reference to the database
    var refUsers : DatabaseReference!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    
    @IBOutlet weak var QRCloseButton: UIButton!
    @IBAction func readQRCloseButton(_ sender: UIButton) {
        performSegue(withIdentifier: "segueReadQRToTabbar", sender: self)
    }
    @IBOutlet weak var qrCodeImageView: UIImageView!
    var video = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //get the reference to the users node in firebase
        self.refUsers = Database.database().reference(withPath: "Users")
        
        //create a session
        let session = AVCaptureSession()
        
        //define capture device
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        }catch{
            print("There was an error!")
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        //bring the button and the sqaure box above the view layer to display on top of video
        self.view.bringSubview(toFront: qrCodeImageView)
        self.view.bringSubview(toFront: QRCloseButton)
        
        //start capturing now using the session
        session.startRunning()
    }
    
    //to process the output, we use the below function
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
                if object.type == AVMetadataObject.ObjectType.qr{
//                    //object.stringvalue gives the value of the QRCode which is the unique id of the user
//                    //get the contact details of the user and store in an array
//
//                    //2. get the reference to the user id present in the object above
//                    let addContactID: String = object.stringValue!
//                    let userToAddRef = refUsers.child(addContactID)
//                    userToAddRef.observe(.value, with: { (snapshot) in
//                        let items = snapshot.value as! [String:AnyObject]
//                        let adddetails: [String:Any] = [
//                            "id" : items["id"] as! String,
//                            "fullname" : items["fullname"] as! String,
//                            "email" : items["email"] as! String,
//                            "phone" : items["phone"] as! String,
//                            "city" : items["city"] as! String
//                        ]
//                        let id = items["id"] as! String
//                        let fullname = items["fullname"] as! String
//                        let email = items["email"] as! String
//                        let phone = items["phone"] as! String
//                        let city = items["city"] as! String
//                        //print the items to check their values if the qr code is generating the correct values
//                        print("id: \(id)")
//                        print("fullname: \(fullname)")
//                        print("email: \(email)")
//                        print("phone: \(phone)")
//                        print("city: \(city)")
//                        //The above statements print correct values
//
//                        //Now, get the reference to the current users key
//                        let currentUserRef = Database.database().reference(withPath: "Users")
//                        let curUserKeyRef = currentUserRef.child((Auth.auth().currentUser?.uid)!)
//                        let curUserContactRef = curUserKeyRef.child("contacts")
//                        let curUserContactKeyRef = curUserContactRef.child("id")
//                        curUserContactKeyRef.setValue(adddetails)
//                        print("Successfully added the contact to the database")
//
//                    })
                    
                    //for now, we display alert controller with the email string.
                    //here, we need to write code, to pull values from the firebaseDB to contacts list
                    //Steps to be performed here are
                    //1. Add the scanned contact to firebase database for the user
                    //2. Then populate the table view with the newly added contact
                    let alert = UIAlertController(title: "QRCode", message: object.stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Copy Code" , style: .default, handler: { (nil) in
                        UIPasteboard.general.string = object.stringValue
                    }))
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    

}
