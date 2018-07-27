//
//  ContactModel.swift
//  iLocate
//
//  Created by Kaushik Reddy Awala on 10/31/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

//Here, we create a model forthe data we have in our database
import Firebase

class ContactModel{
    var id:String
    var fullname:String
    var email:String
    var phone:String
    var city:String
    var key:String
    var ref:DatabaseReference?
    
    init(id:String?, fullname:String?, email:String?, phone:String?, city:String?) {
        self.id = id!
        self.fullname = fullname!
        self.email = email!
        self.phone = phone!
        self.city = city!
        self.ref = nil
        self.key = ""
    }
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        id = snapshotValue["id"] as! String
        fullname = snapshotValue["fullname"] as! String
        email = snapshotValue["email"] as! String
        phone = snapshotValue["phone"] as! String
        city = snapshotValue["city"] as! String
        ref = snapshot.ref
    }
}
