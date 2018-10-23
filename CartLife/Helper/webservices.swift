//
//  webservices.swift
//  Walltones
//
//  Created by Ravi Dubey on 7/4/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import SystemConfiguration
import PKHUD
class webservices: NSObject {

    var baseurl =  "http://ignitiveit.com/cartlife/api/"

    static let sharedInstance : webservices = {
        let instance = webservices()
        return instance
    }()
    func nointernetconnection()
    {
        let button2Alert: UIAlertView = UIAlertView(title: nil, message: "Please check your internet connection",delegate: nil, cancelButtonTitle: "OK")
        button2Alert.show()
        
        
    }
    func AlertBuilder(title:String, message: String) -> UIAlertController{
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    func setShadow(view: UIView)
    {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        view.layer.shadowRadius = 4
    }
    
    func circularimage(imageview:UIImageView)
    {
        imageview.layer.masksToBounds = false
        imageview.layer.cornerRadius = imageview.frame.size.height/2
        imageview.clipsToBounds = true
        
    }
    
    func PaddingTextfiled(textfield:UITextField)
    {
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textfield.frame.height))
        textfield.leftViewMode = .always
    }
    
    func StartSpinner() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
    }
    
    func StopSpinner() {
        PKHUD.sharedHUD.hide(true)
    }
    
    
//    func StartSpinner() {
//        PKHUD.sharedHUD.contentView = PKHUDProgressView()
//        PKHUD.sharedHUD.show()
//    }
//
//    func StopSpinner() {
//        PKHUD.sharedHUD.hide(true)
//    }
    
}
