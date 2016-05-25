//
//  ViewController.swift
//  HueNo1
//
//  Created by Gai on 16/5/13.
//  Copyright © 2016年 Gai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var bridgeSearch: PHBridgeSearching!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Search for bridges to get address of a bridge
        bridgeSearch = PHBridgeSearching.init(upnpSearch: true, andPortalSearch: true, andIpAdressSearch: true)
        bridgeSearch.startSearchWithCompletionHandler { (bridgesFound: [NSObject : AnyObject]!) -> Void in
            
            if bridgesFound.count > 0 {
                
                // Configure SDK connection
                let sortedKeys: Array = bridgesFound.keys.sort({ (s1, s2) -> Bool in
                    return (s1 as! String) < (s2 as! String)
                })
                let bridgeId = sortedKeys[0] as! String
                let ip = bridgesFound[bridgeId] as! String
                UIAppDelegate.phHueSDK.setBridgeToUseWithId(bridgeId, ipAddress: ip)

                // Authorize/pushlink your app
                let phNotificationMgr: PHNotificationManager = PHNotificationManager.defaultManager()
                phNotificationMgr.registerObject(self, withSelector: #selector(self.authenticationSuccess), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
                phNotificationMgr.registerObject(self, withSelector: #selector(self.authenticationFailed), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
                phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalConnection), forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
                phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalBridge), forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
                phNotificationMgr.registerObject(self, withSelector: #selector(self.buttonNotPressed), forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
                UIAppDelegate.phHueSDK.startPushlinkAuthentication()
                
                // Enable local connection
                phNotificationMgr.registerObject(self, withSelector: #selector(self.localConnection), forNotification: LOCAL_CONNECTION_NOTIFICATION)
                phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
                phNotificationMgr.registerObject(self, withSelector: #selector(self.notAuthenticated), forNotification: NO_LOCAL_AUTHENTICATION_NOTIFICATION)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Handle the pushlink events
    func authenticationSuccess() {
        UIAppDelegate.phHueSDK.enableLocalConnection()
        print("goodjob")
        self.performSelector(#selector(presentControlLightsViewController), withObject: nil, afterDelay: 2.0)
    }
    func authenticationFailed() {
        
    }
    func noLocalConnection() {
        
    }
    func noLocalBridge() {
        
    }
    func buttonNotPressed() {
        
    }
    
    // Handle connection events
    func localConnection() {
//        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        let controlLightsView = mainStoryBoard.instantiateViewControllerWithIdentifier("ControlLightsViewController") as! ControlLightsViewController
//        self.presentViewController(controlLightsView, animated: true, completion: nil)
//        PHNotificationManager.defaultManager().deregisterObject(self, forNotification: LOCAL_CONNECTION_NOTIFICATION)
    }

    func notAuthenticated() {
        
    }
    
    func presentControlLightsViewController() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let controlLightsViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ControlLightsViewController") as! ControlLightsViewController
        self.presentViewController(controlLightsViewController, animated: true, completion: nil)
    }

}

