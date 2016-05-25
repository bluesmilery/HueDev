//
//  BridgePushLinkViewController.swift
//  HueNo1
//
//  Created by Gai on 16/5/20.
//  Copyright © 2016年 Gai. All rights reserved.
//

import UIKit

class BridgePushLinkViewController: UIViewController {

    @IBOutlet var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 开始推送认证链接
    func startPushLink() {
        
        let phNotificationMgr: PHNotificationManager = PHNotificationManager.defaultManager()
        phNotificationMgr.registerObject(self, withSelector: #selector(self.authenticationSuccess), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
        phNotificationMgr.registerObject(self, withSelector: #selector(self.authenticationFailed), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
        phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalConnection), forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
        phNotificationMgr.registerObject(self, withSelector: #selector(self.noLocalBridge), forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
        phNotificationMgr.registerObject(self, withSelector: #selector(self.buttonNotPressed(_:)), forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
        
        UIAppDelegate.phHueSDK.startPushlinkAuthentication()
    }
    
    // 认证成功
    func authenticationSuccess() {
        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)

        UIAppDelegate.pushLinkSuccess()
        
    }
    func authenticationFailed() {
        
    }
    func noLocalConnection() {
        
    }
    func noLocalBridge() {
        
    }
    func buttonNotPressed(notification: NSNotification) {
        let dict: Dictionary = notification.userInfo!
        let progressPercentage: Float = dict["progressPercentage" as NSObject] as! Float / 100.0
        progressView.progress = progressPercentage
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
