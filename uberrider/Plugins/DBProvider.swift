//
//  DBProvider.swift
//  uberrider
//
//  Created by mac on 8/5/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import Firebase
class DBProvider {
    private static let _instance=DBProvider()
    static var Instance:DBProvider{
        return _instance
    }
    // database refrence
    
    var dbRef:DatabaseReference{
        return Database.database().reference()
    }
    
    var ridersRef:DatabaseReference{
        return dbRef.child(Constants.RIDERS)
    }
    
    
    // request ref
    
    var requestRef:DatabaseReference{
        return dbRef.child(Constants.UBER_REQUEST)
    }
    
    
    
    //request Accepted
    var requestRefAccept:DatabaseReference{
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
    
    func saveUser(ID:String,EMAIL:String,PASSWORD:String)  {
        let data:Dictionary<String,Any>=[Constants.EMAIL:EMAIL,Constants.PASSWORD:PASSWORD,Constants.isRider:true]
        
        
        ridersRef.child(ID).child(Constants.DATA).setValue(data)
    }
}
