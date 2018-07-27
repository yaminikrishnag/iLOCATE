//
//  ContactsTableViewController.swift
//  iLocate
//
//  Created by Kaushik Reddy Awala on 10/31/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MessageUI

class ContactsTableViewController: UITableViewController,  MFMessageComposeViewControllerDelegate{

    @IBOutlet var tblContacts: UITableView!
    
    //firebase database reference for retrieving the contacts from firebase
    var refUsers = Database.database().reference(withPath: "Users")
    
    var contactList = [ContactModel]()
    var phone: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //referencing the child of Users, that is the current user's user id in JSON
        let userChildRef = self.refUsers.child((Auth.auth().currentUser?.uid)!)
        userChildRef.observe(.value) { (snapshot) in
            //print(snapshot)
        } //this works
        
        //referencing the json string of contacts of the current user
        let userContactRef = userChildRef.child("contacts")
        userContactRef.observe(.value) { (snapshot) in
            if let contacts = snapshot.children.allObjects as? [DataSnapshot]{
                var newitems = [ContactModel]()
                for contact in contacts {
                    let contactid = contact.key as String //get the id of contact
                    userContactRef.child("\(contactid)/").observe(.value, with: { (snapshot) in
                        if snapshot.childrenCount > 0{
                            //self.contactList.removeAll()
                            let items = snapshot.value as! [String : AnyObject]
                            let id = items["id"] as! String
                            let fullname = items["fullname"] as! String
                            let email = items["email"] as! String
                            let phone = items["phone"] as! String
                            let city = items["city"] as! String
                            
                            //print the contact details of all the contacts for the current user
//                            print("id: \(id)")
//                            print("fullname: \(fullname)")
//                            print("email: \(email)")
//                            print("phone: \(phone)")
//                            print("city: \(city)")
                            
                            //collect all the values of a contact and store them in a list
                            let usercontact = ContactModel(id: id as String?, fullname: fullname as String?, email: email as String?, phone: String(phone) as String?, city: city as String?)
                            //add this contact to the list
                            newitems.append(usercontact)
                            //check to see if the items exist in the array
//                            for item in newitems{
//                                print(item)
//                            }
                            self.contactList = newitems
//                            for c in self.contactList{
//                                print(c)
//                            }
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        } //this works
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult){
        if result == .cancelled{
            print("Message sent succesfully")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sms(phone: String){
        if MFMessageComposeViewController.canSendText(){
            let smsvc = MFMessageComposeViewController()
            smsvc.messageComposeDelegate = self
            smsvc.recipients = [phone]
            present(smsvc, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print("Contact List Count: \(contactList.count)")
        return contactList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let users:ContactModel
        
        users = contactList[indexPath.row]
        // Configure the cell...
        let lblFullName = cell.viewWithTag(1) as! UILabel
        let lblEmail = cell.viewWithTag(2) as! UILabel
        let lblPhone = cell.viewWithTag(3) as! UILabel
        //let lblCity = cell.viewWithTag(4) as! UILabel
        let contactImage = cell.viewWithTag(4) as! UIImageView
        
        //print the values to check if they are being set here
//        print("fullname: \(users.fullname ?? "Unknown Fullname")")
//        print("email: \(users.email ?? "Unknown email")")
//        print("phone: \(users.phone ?? "Unknown Phone")")
        //print("city: \(users.city ?? "Unknown City")")
        
        lblFullName.text = users.fullname
        lblEmail.text = users.email
        lblPhone.text = users.phone
        //lblCity.text = users.city
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let phone = contactList[indexPath.row].phone
        sms(phone: phone)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
