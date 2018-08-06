//
//  UberHandler.swift
//  uberrider
//
//  Created by mac on 8/5/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import Firebase

protocol UberController:class {
    func canCallUber(delegateCalled:Bool)
    func driverAcceptedRequest(requestAccepted:Bool,driverName:String)
    func updateDriversLocation(lat:Double,lng:Double)
    
}


class UberHandler {
    
    private static let _instance=UberHandler()
    
    weak var delegate:UberController?
    
    var rider=""
    var driver=""
    var rider_id=""
    
    
    static var Instance:UberHandler{
        return _instance
    }
    
    
    func observeMessageForRider()  {
        
        
        //rider request uber
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot:DataSnapshot) in
            
            
            
            if let data=snapshot.value   as? NSDictionary{
                if let name=data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.rider_id=snapshot.key
                        print("rider id is \(self.rider_id)")
                        self.delegate?.canCallUber(delegateCalled: true)
                        
                    }
                }
            }
            
        }
        
        // rider cancel uber
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
            
            
            
            if let data=snapshot.value   as? NSDictionary{
                if let name=data[Constants.NAME] as? String{
                    if name == self.rider{
                      
                        self.delegate?.canCallUber(delegateCalled: false)
                        
                    }
                }
            }
            
        }
        
        
        // Rider Cancel Uber
        
        DBProvider.Instance.requestRefAccept.observe(DataEventType.childAdded) { (snapshot:DataSnapshot) in
            
            if  let data = snapshot.value as? NSDictionary {
                if let name=data[Constants.NAME] as? String{
                    if self.driver == ""{
                        
                        self.driver=name
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver)
                    }
                }
            }
            
        }
        
        // driver cancel
        
         DBProvider.Instance.requestRefAccept.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
            
            if  let data = snapshot.value as? NSDictionary {
                if let name=data[Constants.NAME] as? String{
                    if name==self.driver{
                        self.driver=""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                        
                        
                    }
                }
            }
            
        }
        
        
        
        
        
        // Driver Update location
        
        DBProvider.Instance.requestRefAccept.observe(DataEventType.childChanged) { (snapshot:DataSnapshot) in
            
            if  let data = snapshot.value as? NSDictionary {
                if let name=data[Constants.NAME] as? String{
                    
                    if name==self.driver{
                        
                        if let lat=data[Constants.LATITUDE] as? Double{
                            if let lng=data[Constants.LONGITUDE] as? Double{
                                self.delegate?.updateDriversLocation(lat: lat, lng: lng)
                            }
                        }
                        
                    }
                }
            }
            
        }
        
    }
    
    
    
    // request uber
    func requestUber(latitude:Double,longitude:Double)  {
        let data:Dictionary<String,Any>=[Constants.NAME:rider,Constants.LATITUDE:latitude,Constants.LONGITUDE:longitude]
        
    DBProvider.Instance.requestRef.childByAutoId().setValue(data)
        
        
    }
    
    
    // cancelUber
    func cancelUber()  {
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
    }
    
    
    
    //update
    func  updateRiderLocation(lat:Double,long:Double){
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE:lat,Constants.LONGITUDE:long])
    }
}
