//
//  AppDelegate.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/18/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate, MessagingDelegate  {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GMSServices.provideAPIKey("AIzaSyC2k9gtTgJxihdaJQ99T7tSs77b_fPA3l0")
        GMSPlacesClient.provideAPIKey("AIzaSyC2k9gtTgJxihdaJQ99T7tSs77b_fPA3l0")
        IQKeyboardManager.sharedManager().enable = true
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 5))

        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            Messaging.messaging().delegate = self
            
        }
        application.registerForRemoteNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)

        if(UserDefaults.standard.object(forKey:"userid") != nil)
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
            navigationController.pushViewController(initialViewController, animated: true)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
        else
        {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        navigationController.pushViewController(initialViewController, animated: true)
                        self.window?.rootViewController = navigationController
                        self.window?.makeKeyAndVisible()
        
        }
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let user = UserDefaults.standard
        user.set(fcmToken,forKey:"FcmToken")
        user.synchronize()
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    @objc func tokenRefreshNotification(notification: NSNotification) {
        // NOTE: It can be nil here
        let refreshedToken = InstanceID.instanceID().token()
        print("InstanceID token: \(String(describing: refreshedToken))")
        
        connectToFcm()
    }
    func connectToFcm() {
        Messaging.messaging().connect { (error) in
            if (error != nil) {
                Messaging.messaging().shouldEstablishDirectChannel = true
                
                print("Unable to connect with FCM. \(String(describing: error))")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication =  options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        
        let facebookHandler = FBSDKApplicationDelegate.sharedInstance().application (
            app,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation )
        
        return facebookHandler
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    {
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

