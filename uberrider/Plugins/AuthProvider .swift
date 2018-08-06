//
//  AuthProvider .swift
//  uberrider
//
//  Created by mac on 8/5/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import Firebase
// error handler
typealias loginHandler = (_ msg:String?) -> Void

// handle errors
struct loginErrorCode {
    static let  Invaled_Email="Invalid Email Address,Please Provide A Real Email Address."
    static let  wrong_password="Wrong passord."
    
    static let  problem_connecting="problem to connect to database."
    static let  userNotFound="User Not Found, Register."
    
    static let  EmailUser="Email Already In Use,try another Email."
    
    
    static let  weakPassword="Weak Password must have at least 6 character."
    
}

class AuthProvider {
    private static let _instance=AuthProvider()
    static var Instance:AuthProvider{
        return _instance
    }
    
    
    // login
    func login(Email:String,Password:String,loginhandler:loginHandler?)  {
        Auth.auth().signIn(withEmail: Email, password:Password ) { (user, error) in
            
            
            if error != nil{
                self.handleErrors(err: error as! NSError, loginhandler: loginhandler)
            }else{
                loginhandler?(nil)
            }
        }
    }
    // register
    
    // register
    func register(Email:String,Password:String,loginhandler:loginHandler?)  {
        Auth.auth().createUser(withEmail: Email, password:Password ) { (user, error) in
            
            
            if error != nil{
                self.handleErrors(err: error as! NSError, loginhandler: loginhandler)
            }else{
                if user?.user.uid != nil {
                    // store user to database
                    DBProvider.Instance.saveUser(ID:  user!.user.uid, EMAIL: Email, PASSWORD: Password)
                    
                    // login in user
                    
                    self.login(Email: Email, Password: Password, loginhandler: loginhandler)
                }
            }
        }
    }
    
    
    
    func logOut() -> Bool{
        if Auth.auth().currentUser != nil {
            do {
               try Auth.auth().signOut()
                return true
            }catch{
                return false
            }
        }
        return true
    }
    
    private func handleErrors(err:NSError,loginhandler:loginHandler?){
        if let errorCode=AuthErrorCode(rawValue: err.code){
            switch errorCode{
            case .wrongPassword:
                loginhandler?(loginErrorCode.wrong_password)
                break
                
            case .invalidEmail:
                loginhandler?(loginErrorCode.Invaled_Email)
                
                break
                
            case .userNotFound:
                loginhandler?(loginErrorCode.userNotFound)
                break
                
            case .emailAlreadyInUse:
                loginhandler?(loginErrorCode.EmailUser)
                break
                
            case .weakPassword:
                loginhandler?(loginErrorCode.weakPassword)
                break
            default:
                loginhandler?(loginErrorCode.problem_connecting)
                break
                
                
                
            }
        }
    }
}
