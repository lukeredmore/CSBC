//
//  AppDelegate.swift
//  CSBC
//
//  Created by Luke Redmore on 1/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import GoogleSignIn

///Configure Firebase, download Lunch Menus, queue local notifications, setup UI defaults
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        print("Application successfully loaded: Version \(Bundle.versionString)")
        
        LunchMenuRetriever.downloadLunchMenus()
        DaySchedule.retrieveFromFirebase()
        
        //Notifications
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self as? MessagingDelegate
        Messaging.messaging().subscribe(toTopic: "appUser")
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if granted { DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            } }
        }
        return true
    }
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().token { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Device registered for remote notifiations. Remote instance ID token: \(result)")
                Messaging.messaging().apnsToken = deviceToken
                NotificationController.subscribeToPushNotificationTopics()
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Updating local notifications in background")
        //Call this completion handler after running background task
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    // Receive displayed notifications for iOS 10 devices.
//    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
//        //print(remoteMessage.appData)
//    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) { }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootVC = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController),  (rootVC.responds(to: #selector(LunchViewController.canRotate)) || rootVC.responds(to: #selector(ActualDocViewController.canRotate))) { return .allButUpsideDown }
            return .portrait
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        guard let rootVC = rootViewController else { return nil }
        if rootVC.isKind(of: UITabBarController.self) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
        if (response.notification.request.content.title == "Time to check-in!") {
            /* Change root view controller to a specific viewcontroller */
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "homeViewController") as? HomeViewController
            self.window?.rootViewController = vc
            vc?.performSegue(withIdentifier: "CovidSegue", sender: nil)
        }
        
        completionHandler()
    }
}

