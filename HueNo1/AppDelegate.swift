//
//  AppDelegate.swift
//  HueNo1
//
//  Created by Gai on 16/5/13.
//  Copyright © 2016年 Gai. All rights reserved.
//

import UIKit
import CoreData

let UIAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var phHueSDK: PHHueSDK!
    var bridgeSearch: PHBridgeSearching!
    
    var mainStoryBoard: UIStoryboard!
    var viewController: ViewController!
    var loadingViewController: LoadingViewController!
    var bridgePushLinkViewController: BridgePushLinkViewController!
    var controlLightsViewController: ControlLightsViewController!
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // 初始化SDK
        phHueSDK = PHHueSDK.init()
        phHueSDK.startUpSDK()
        phHueSDK.enableLogging(true)
        
        mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        viewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
        // 启动事件监听
        let notificationManager: PHNotificationManager = PHNotificationManager.defaultManager()
        notificationManager.registerObject(self, withSelector: #selector(localConnection), forNotification: LOCAL_CONNECTION_NOTIFICATION)
        notificationManager.registerObject(self, withSelector: #selector(noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
        notificationManager.registerObject(self, withSelector: #selector(notAuthenticated), forNotification: NO_LOCAL_AUTHENTICATION_NOTIFICATION)
        
        startConnect()
        
        return true
    }
    
    
    // 处理监听事件
    func localConnection() {
        if (controlLightsViewController == nil) {
            self.performSelector(#selector(presentControlLightsViewController), withObject: nil, afterDelay: 1)
        }
    }
    func noLocalConnection() {
        
    }
    func notAuthenticated() {
//        removeLoadingView()
        self.performSelector(#selector(doAuthenticated), withObject: nil, afterDelay: 0.5)
    }
    
    // 进行身份验证
    func doAuthenticated() {
        phHueSDK.disableLocalConnection()
        bridgePushLinkViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("BridgePushLinkViewController") as! BridgePushLinkViewController
        viewController.presentViewController(bridgePushLinkViewController, animated: true, completion: {
            self.bridgePushLinkViewController.startPushLink()
        })
    }
    
    // 进行连接
    func startConnect() {
        let cache: PHBridgeResourcesCache = PHBridgeResourcesReader.readBridgeResourcesCache()
        if (cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
            self.showLoadingView("Connecting...")
            phHueSDK.enableLocalConnection()
        } else {
            searchBridge()
        }
    }
    
    // 寻找桥接器
    func searchBridge() {
        phHueSDK.disableLocalConnection()
        
        showLoadingView("Searching...")
        
        bridgeSearch = PHBridgeSearching.init(upnpSearch: true, andPortalSearch: true, andIpAdressSearch: true)
        bridgeSearch.startSearchWithCompletionHandler { (bridgesFound: [NSObject : AnyObject]!) -> Void in
            
            if bridgesFound.count > 0 {
                
                // Configure SDK connection
                let sortedKeys: Array = bridgesFound.keys.sort({ (s1, s2) -> Bool in
                    return (s1 as! String) < (s2 as! String)
                })
                let bridgeId = sortedKeys[0] as! String
                let ip = bridgesFound[bridgeId] as! String
                self.showLoadingView("Connecting...")
                self.phHueSDK.setBridgeToUseWithId(bridgeId, ipAddress: ip)
                
                self.performSelector(#selector(self.startConnect), withObject: nil, afterDelay: 1)
            } else {
                // 没有发现桥接器，弹出警告
            }
        }
    }
    
    // 连接成功
    func pushLinkSuccess() {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        self.performSelector(#selector(startConnect), withObject: nil, afterDelay: 1)
    }
    
    // 呈现控制界面
    func presentControlLightsViewController() {
        controlLightsViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ControlLightsViewController") as! ControlLightsViewController
        viewController.presentViewController(controlLightsViewController, animated: true, completion: nil)
    }
    
    func showLoadingView(withText: String) {
        // 先移除旧的
        removeLoadingView()
        
        // 再产生新的
        loadingViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("LoadingViewController") as! LoadingViewController
        loadingViewController.view.frame = viewController.view.bounds
        viewController.view.addSubview(loadingViewController.view)
        loadingViewController.loadingText.text = withText
    }
    
    func removeLoadingView() {
        if (loadingViewController != nil) {
            loadingViewController.view.removeFromSuperview()
            loadingViewController = nil
        }
    }
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        phHueSDK.disableLocalConnection()
        viewController.dismissViewControllerAnimated(true, completion: nil)
        controlLightsViewController = nil
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        startConnect()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.421.HueNo1" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("HueNo1", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

