//
//  SignUpViewController.swift
//  iLocate
//
//  Created by Aparna Shriraksha KN on 10/30/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var signupScrollView: UIScrollView!
    @IBOutlet weak var signupFullNameTextField: UITextField!
    @IBOutlet weak var signupEmailTextField: UITextField!
    @IBOutlet weak var signupPasswordTextField: UITextField!
    @IBOutlet weak var signupPhoneTextField: UITextField!
    @IBOutlet weak var signupCityTextField: UITextField!
    
    //Firebase Database Reference for users
    var refUsers: DatabaseReference!
    
    //Firebase DB reference for errorLog
    var refErrors: DatabaseReference!
    
    //Actions
    @IBAction func signupSignUpButton(_ sender: UIButton) {
        if signupEmailTextField.text == "" || signupFullNameTextField.text == "" || signupPasswordTextField.text == "" || signupCityTextField.text == "" || signupPhoneTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "All fields are mandatory!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().createUser(withEmail: self.signupEmailTextField.text!, password: self.signupPasswordTextField.text!) { (user, error) in
                
                if error == nil {
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    // Add user to the Firebase database
                    self.addUserToFirebaseDB()
                    print("Signup recorded. Following are the details...")
                    print("\nUser: \(self.signupFullNameTextField.text!)\nEmail: \(self.signupEmailTextField.text!)")
                    //Display Notification to the user that signup has been successful
                    let alertController = UIAlertController(title: "Success", message: "Signup successful!", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                        //Redirect the user to the login page here. A user cannot login until one verifies one's email
                        //perform segue operation here
                        self.performSegue(withIdentifier: "segueSignupToLogin", sender: self)
                    })
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
//                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    //log error
                    self.logErrorToFirebaseDB(err: error!)
                }
            }
        }
    }
    @IBAction func signupCancelButton(_ sender: UIButton) {
    }
    
    //function to add user to the firebase database
    func addUserToFirebaseDB() {
        let userChildRef = self.refUsers.child((Auth.auth().currentUser?.uid)!)
        let values : [String:Any] = [
            "id": Auth.auth().currentUser?.uid as Any,
            "fullname": signupFullNameTextField.text!,
            "email":signupEmailTextField.text!,
            "phone":signupPhoneTextField.text!,
            "city":signupCityTextField.text!,
            "contacts":[String : Any](),
            "pic":""
        ]
        userChildRef.setValue(values)
        //print the message to the console to check if the user has been added or not
        print("User has been added to the database successfully")
    }
    
    //function to log error to the firebase database
    func logErrorToFirebaseDB(err:Error) {
        let errorkey = refUsers.childByAutoId().key
        //Now assign all the values of an error to this error key
        let error = [
            "id":errorkey,
            "ErrorDescription": err.localizedDescription as String
        ]
        
        //Now, add error inside the new generated unique key
        refErrors.child(errorkey).setValue(error)
        
        //print the message to the console to check if the error has been logged in case of failure
        print("Error has been logged to the database successfully")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Get the reference to Users
        //refUsers = Database.database().reference().child("Users")
        refUsers = Database.database().reference(withPath: "Users")
        refErrors = Database.database().reference().child("Errors")
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
        // An idea is here to pass the value of email that the user signed up with to the login
         // view controller to save user time to enter the email address
         let dvc = segue.destination as! LoginViewController
         dvc.signupEmail = self.signupEmailTextField.text!
    }
    */
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag
        {
        case 0...2 :
            print(" ")
        default : signupScrollView.setContentOffset(CGPoint(x:0,y:100), animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        signupScrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
