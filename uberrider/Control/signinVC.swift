//
//  ViewController.swift
//  uberrider
//
//  Created by mac on 8/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class signinVC: UIViewController {

    private let Rider_Segue="RiderVC"
    
    
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func registerButton(_ sender: Any) {
        
        
        if emailTF.text != "" && passwordTF.text != "" {
            AuthProvider.Instance.register(Email: emailTF.text!, Password: passwordTF.text!) { (message) in
                if message != nil {
                    self.alert(title: "problem to create new user", message: message!)
                }else{
                    
                    // create user and login
                    // segue to map
                    print("creating user is completed")
                    UberHandler.Instance.rider=self.emailTF.text!
                    self.emailTF.text=""
                    self.passwordTF.text=""
                    self.performSegue(withIdentifier: self.Rider_Segue, sender: nil)
                }
            }
        }else{
            alert(title: "Email And Password is Require", message: "Please not Empty")
        }
    }
    @IBAction func loginButton(_ sender: Any) {
        if emailTF.text != "" && passwordTF.text != "" {
            AuthProvider.Instance.login(Email: emailTF.text!, Password: passwordTF.text!) { (message) in
                if message != nil {
                    self.alert(title: "error with Auth", message: message!)
                }else{
                    print("login Success")
                    UberHandler.Instance.rider=self.emailTF.text!
                    self.emailTF.text=""
                    self.passwordTF.text=""
                    self.performSegue(withIdentifier: self.Rider_Segue, sender: nil)
                    
                }
            }
        }
        
    }
    
    
    private func alert(title:String,message:String){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok=UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
}

