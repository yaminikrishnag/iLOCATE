//
//  LoginViewController.swift
//  iLocate
//
//  Created by Aparna Shriraksha KN on 10/30/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
   
    //Actions
    @IBAction func loginLoginButton(_ sender: UIButton) {
        if self.loginEmailTextField.text == "" || self.loginPasswordTextField.text == "" {
            
            //Alert the user if the fields are empty
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: self.loginEmailTextField.text!, password: self.loginPasswordTextField.text!) { (user, error) in
                
                if error == nil {
                    if Auth.auth().currentUser?.isEmailVerified == true{
                        //Print into the console if successfully logged in
                        print("User has successfully logged in")
                        print(Auth.auth().currentUser?.email ?? "User email not found")
                        
                        //Go to the HomeViewController if the login is sucessful
//                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
//                        self.present(vc!, animated: true, completion: nil)
                        //perform segue to the profile page of the application
                        self.performSegue(withIdentifier: "segueLoginToTabbar", sender: self)
                        //for now, usethe alert notificstion
//                        let alertController = UIAlertController(title: "Success", message: "Login successful!", preferredStyle: .alert)
//                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alertController.addAction(defaultAction)
//                        self.present(alertController, animated: true, completion: nil)
                    }
                    else{
                        let alertController = UIAlertController(title: "Error", message: "Please verify your email before you login!", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func loginForgotPasswordButton(_ sender: UIButton) {
    }
    @IBAction func loginSignUpButton(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
