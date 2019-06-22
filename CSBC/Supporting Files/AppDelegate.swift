//
//  AppDelegate.swift
//  CSBC
//
//  Created by Luke Redmore on 1/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let userDefaults = UserDefaults.standard
    var window: UIWindow?
    let notificationKeys = ["showSetonNotifications","showJohnNotifications","showSaintsNotifications","showJamesNotifications"]
    var notificationSettings : NotificationSettings!
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        //MARK: - Firebase
        FirebaseApp.configure()
        
        
        //MARK: - Navigation Bar
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "gotham", size: 30)!, NSAttributedString.Key.foregroundColor: UIColor(named: "CSBCNavBarText")!]
    
    
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "gotham", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor(named: "CSBCNavBarText")!], for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "gotham", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor(named: "CSBCNavBarText")!], for: .highlighted)
        
        
        
        //MARK: - Notifications
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self as? MessagingDelegate
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            self.checkForNotificationProperties()
            if granted {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
        
        return true
    }
    
    func checkForNotificationProperties(redefineOverride : Bool = false) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            let userDefinedSettingsExist = self.userDefaults.value(forKey: "shouldDeliverNotifications") != nil && self.userDefaults.value(forKey: "timeOfNotificationDeliver") != nil && self.userDefaults.value(forKey: "showSetonNotifications") != nil && self.userDefaults.value(forKey: "showJohnNotifications") != nil && self.userDefaults.value(forKey: "showSaintsNotifications") != nil && self.userDefaults.value(forKey: "showJamesNotifications") != nil
            
            if settings.authorizationStatus == .authorized && (self.userDefaults.value(forKey: "Notifications") == nil || redefineOverride) {
                // Already authorized
                if userDefinedSettingsExist { //3
                    print("Device has user defined settings and wants to receive notifications")
                    let notifs = NotificationSettings(
                        shouldDeliver: self.userDefaults.bool(forKey: "shouldDeliverNotifications"),
                        deliveryTime: self.userDefaults.string(forKey: "timeOfNotificationDeliver")!,
                        schools: [
                            self.userDefaults.bool(forKey: "showSetonNotifications"),
                            self.userDefaults.bool(forKey: "showJohnNotifications"),
                            self.userDefaults.bool(forKey: "showSaintsNotifications"),
                            self.userDefaults.bool(forKey: "showJamesNotifications")
                        ],
                        valuesChangedByUser: true)
                    self.userDefaults.set(try? PropertyListEncoder().encode(notifs), forKey: "Notifications")
                } else { //1
                    print("Device doesn't have defined settings and wants to receive notifications")
                    let notifs = NotificationSettings(
                        shouldDeliver: true,
                        deliveryTime: "7:00 AM",
                        schools: [true, true, true, true],
                        valuesChangedByUser: false)
                    self.userDefaults.set(try? PropertyListEncoder().encode(notifs), forKey: "Notifications")
                }
            }
            else if self.userDefaults.value(forKey: "Notifications") == nil || redefineOverride {
                // Either denied or notDetermined
                if userDefinedSettingsExist { //4
                    print("Device has user defined settings and doesn't want to receive notifications")
                    let notifs = NotificationSettings(
                        shouldDeliver: false,
                        deliveryTime: self.userDefaults.string(forKey: "timeOfNotificationDeliver")!,
                        schools: [
                            self.userDefaults.bool(forKey: "showSetonNotifications"),
                            self.userDefaults.bool(forKey: "showJohnNotifications"),
                            self.userDefaults.bool(forKey: "showSaintsNotifications"),
                            self.userDefaults.bool(forKey: "showJamesNotifications")
                        ],
                        valuesChangedByUser: true)
                    self.userDefaults.set(try? PropertyListEncoder().encode(notifs), forKey: "Notifications")
                } else { //2
                    print("Device doesn't have user defined settings and doesn't want to receive notifications")
                    let notifs = NotificationSettings(
                        shouldDeliver: false,
                        deliveryTime: "7:00 AM",
                        schools: [true, true, true, true],
                        valuesChangedByUser: false)
                    self.userDefaults.set(try? PropertyListEncoder().encode(notifs), forKey: "Notifications")
                }
            } else {
                print("Device has clearly defined settings in the new 'Notifications' struct")
                self.notificationSettings = self.defineNotificationSettings()
                print(self.notificationSettings!)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("jkhgkjhj")
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Device registered for remote notifiations. Remote instance ID token: \(result.token)")
            }
        })
        Messaging.messaging().apnsToken = deviceToken
        InstanceID.instanceID().instanceID { (result, _) in
            if result != nil {
                let notificationController = NotificationController()
                notificationController.subscribeToTopics()
                notificationController.queueNotifications()
            }
        }
    }

    
    
    // Receive displayed notifications for iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        //print(remoteMessage.appData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //let userInfo = notification.request.content.userInfo
        //print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler(.alert)
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
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path

        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {

                    if (fileName.hasSuffix(".pdf"))
                    {
                        let filePathName = "\(documentPath)/\(fileName)"
                        try fileManager.removeItem(atPath: filePathName)
                    }
                }

                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache after deleting images: \(files)")
            }

        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
    }
    
//    var completionHandlers = [String : () -> Void]()
//    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
//
//        completionHandlers[identifier] = completionHandler
//    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController.responds(to: #selector(LunchViewController.canRotate))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            } else if (rootViewController.responds(to: #selector(ActualDocViewController.canRotate))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            }
        }
        
        // Only allow portrait (standard behaviour)
        return .portrait;
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: UITabBarController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
    
    func defineNotificationSettings() -> NotificationSettings {
        if let data = UserDefaults.standard.value(forKey:"Notifications") as? Data {
            let notificationSettings = try? PropertyListDecoder().decode(NotificationSettings.self, from: data)
            return notificationSettings!
        } else {
            let notificationSettings = NotificationSettings(shouldDeliver: true, deliveryTime: "7:00 AM", schools: [true, true, true, true], valuesChangedByUser: false)
            return notificationSettings
        }
    }
}

