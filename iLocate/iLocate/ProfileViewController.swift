//
//  ProfileViewController.swift
//  iLocate
//
//  Created by Kaushik Reddy Awala on 10/31/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileEditLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileFullNameLabel: UILabel!
    @IBOutlet weak var profileEmailLabel: UILabel!
    @IBOutlet weak var profilePhoneLabel: UILabel!
    @IBOutlet weak var profileCityLabel: UILabel!
    @IBAction func profileLogoutButton(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "segueProfileToLogin", sender: self)
        } catch let signoutError as NSError {
            print("Error Signing out: %@", signoutError)
        }
    }
    
    var profileRef:DatabaseReference!
    let storageRef = Storage.storage().reference()
    let rootRef = Database.database().reference(withPath: "Users")
    
    //function to save the image in firebase DB of the user
    func save() {
        let imagename = NSUUID().uuidString
        let storedImage = storageRef.child("profile_images").child(imagename)
        if let uploadData = UIImagePNGRepresentation(self.profilePhoto.image!)
        {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString{
                        self.rootRef.child((Auth.auth().currentUser?.uid)!).updateChildValues(["pic" : urlText], withCompletionBlock: { (error, ref) in
                            if error != nil{
                                print(error!)
                                return
                            }
                        })
                    }
                })
            })
        }
    }
    //function to present the UIImagePicker Controller
    func uploadImage() {
        let picker = UIImagePickerController()
        picker.delegate=self
        picker.allowsEditing=true
        picker.sourceType=UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add the code
        profilePhoto.layer.cornerRadius=profilePhoto.frame.size.width/2
        profilePhoto.clipsToBounds=true
        //call the function setProfileImage
        setProfileImage()
        
        //Tap Recognizers
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.imageTapped(recognizer:)))
        tapGesture1.numberOfTapsRequired = 1
        self.profilePhoto.isUserInteractionEnabled = true
        self.profilePhoto.addGestureRecognizer(tapGesture1)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.labelTapped(recognizer:)))
        tapGesture2.numberOfTapsRequired = 1
        self.profileEditLabel.isUserInteractionEnabled = true
        self.profileEditLabel.addGestureRecognizer(tapGesture2)
    }
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("This device doesn't have a camera.")
            return
        }
        let imagepicker = UIImagePickerController()
        imagepicker.sourceType = .camera
        imagepicker.cameraDevice = .rear
        //        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagepicker.mediaTypes = UIImagePickerController.availableMediaTypes(for:.camera)!
        imagepicker.delegate=self
        imagepicker.allowsEditing = true
        self.present(imagepicker, animated: true,completion: nil)
    }
    
    // Do any additional setup after loading the view.
    //function to set the profile image of the user after editing
    func setProfileImage(){
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        profilePhoto.clipsToBounds = true
        
        let userIDRef = rootRef.child((Auth.auth().currentUser?.uid)!)
        userIDRef.observe(.value) { (snapshot) in
            let items = snapshot.value as! [String:AnyObject]
            self.profileFullNameLabel.text = items["fullname"] as? String
            self.profileEmailLabel.text = items["email"] as? String
            self.profilePhoneLabel.text = items["phone"] as? String
            self.profileCityLabel.text = items["city"] as? String
            if let profileImageURL = items["pic"] as? String
            {
                if items["pic"] as! String == ""{
                    
                    self.profilePhoto?.image = #imageLiteral(resourceName: "defaultphoto")
                }
                else {
                    
                    
                    let url = URL(string: profileImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil{
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            self.profilePhoto?.image = UIImage(data: data!)
                        }
                    }).resume()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeImage(){
        let urlText = ""
        print("delete pic")
        self.rootRef.child((Auth.auth().currentUser?.uid)!).updateChildValues(["pic" : urlText], withCompletionBlock: { (error, ref) in
            if error != nil{
                print(error!)
                return
            }
        })
        setProfileImage()
    }
    
    func tapRecognize(){
        let pickOption = UIAlertController(title: "Edit Picture", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        //Choose Photo
        pickOption.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertActionStyle.default, handler: {(action) in
            self.uploadImage()
        }))
        //Take Photo
        pickOption.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default, handler: {(action) in
            self.openCamera()
        }))
        //Delete Photo
        pickOption.addAction(UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler: {(action) in
            self.removeImage()
        }))
        //Cancel Button
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        pickOption.addAction(cancelButton)
        self.present(pickOption, animated: true, completion: nil)
    }

    //image picker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        if let editedImage=info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImage = editedImage
            self.profilePhoto.image=selectedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage=originalImage
            self.profilePhoto.image=selectedImage
        }else{
            //display alert to the user if there is any error
            print("some thing wrong")
        }
        //save the image to the database after choosing the photo from image picker controller
        save()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //dismiss the image Picker Controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(recognizer: UITapGestureRecognizer)
    {
        tapRecognize()
    }
    
    @objc func labelTapped(recognizer: UITapGestureRecognizer)
    {
        tapRecognize()
    }

}
