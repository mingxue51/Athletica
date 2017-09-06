//
//  AppDelegate.swift
//  Athletica
//
//  Created by SilverStar on 6/29/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManager
import Firebase
import Fabric
import Crashlytics

import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

import OneSignal

import SwiftyStoreKit // IAP 1


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSPermissionObserver, OSSubscriptionObserver{

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        IQKeyboardManager.shared().isEnabled = true
        
        Fabric.with([Crashlytics.self])
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        //---------- OneSignal -----------------
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("Received Notification: \(notification!.payload.notificationID)")
            print("launchURL = \(String(describing: notification?.payload.launchURL))")
            print("content_available = \(String(describing: notification?.payload.contentAvailable))")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(payload!.body)")
            print("badge number = \(String(describing: payload?.badge))")
            print("notification sound = \(String(describing: payload?.sound))")
            
            if let data = result!.notification.payload!.additionalData {
                print("data = \(data)")
                
                //----- DEEP LINK and open ChatVC -----
                if Auth.auth().currentUser == nil { return }
                
                // Go to ChatContainerVC
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ChatContainerViewController") as! ChatContainerViewController
                vc.receiverId = data["userId"] as! String
                vc.receiverName = data["userName"] as! String
                vc.receiverPhotoURL = data["userPhotoURL"] as! String
                vc.receiverUserType = data["userType"] as! String
                vc.appDelegate = self
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()                
                //--------------------------------------
//                if let actionSelected = payload?.actionButtons {
//                    print("actionSelected = \(actionSelected)")
//                }
                
                // DEEP LINK from action buttons
//                if let actionID = result?.action.actionID {
//                    
//                    // For presenting a ViewController from push notification action button
//                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                    let instantiateRedViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RedViewControllerID") as UIViewController
//                    let instantiatedGreenViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "GreenViewControllerID") as UIViewController
//                    self.window = UIWindow(frame: UIScreen.main.bounds)
//                    
//                    print("actionID = \(actionID)")
//                    
//                    if actionID == "id2" {
//                        print("do something when button 2 is pressed")
//                        self.window?.rootViewController = instantiateRedViewController
//                        self.window?.makeKeyAndVisible()
//                        
//                        
//                    } else if actionID == "id1" {
//                        print("do something when button 1 is pressed")
//                        self.window?.rootViewController = instantiatedGreenViewController
//                        self.window?.makeKeyAndVisible()
//                        
//                    }
//                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true/*, kOSSettingsKeyInFocusDisplayOption:true*/]
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "fb94ce31-b751-4e77-9480-46eac6789ed6", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)
        //---------------------------------------
        
        
        //----- Tutorial screens -----
        let isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        if isOnboarded {
            setInitialVC()
        }else{
            UserDefaults.standard.set(true, forKey: "isOnboarded")
            // Show OnboardVC
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Onboard", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "OnboardViewController") as! OnboardViewController
            initialViewController.appDelegate = self
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        //----------------------------
        
        self.updateExpiryTimestamp() // IAP 4
        
        completeIAPTransactions() // IAP 2
        
        
        
        return true
    }
    
    // IAP 3
    func completeIAPTransactions() {
        
        // Find the latest expiry date
        // and update it on Firebase DB
        var currentExpiryTimestamp:Double = UserDefaults.standard.double(forKey: "expiryTimestamp")
        var maxTimestamp = currentExpiryTimestamp
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            if purchases.count < 1{ return }
            
            for index in 0 ... purchases.count - 1 {
                let purchase = purchases[index]
                // swiftlint:disable:next for_where
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored{
                    
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase.productId)")
                }
                /*
                if purchase.transaction.transactionState == .restored {
                    
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("restored: \(purchase.productId)")
                    
                    //----- Update the expiry date on Firebase DB -------------------------------
                    let appleValidator = AppleReceiptValidator(service: .production)
                    SwiftyStoreKit.verifyReceipt(using: appleValidator, password: "9ee1ca7b4a99415bb9607081be97a03a") { result in
                        
                        if case .success(let receipt) = result {
                            let purchaseResult = SwiftyStoreKit.verifySubscription(
                                type: .autoRenewable,
                                productId: purchase.productId,
                                inReceipt: receipt)
                            
                            switch purchaseResult {
                            case .purchased(let expiryDate, let receiptItems):
                                print("Product is valid until \(expiryDate)")
                                
                                // Update the max timestamp if possible
                                if expiryDate.timeIntervalSince1970 > maxTimestamp{
                                    maxTimestamp = expiryDate.timeIntervalSince1970
                                }
                                
                                // Update the timestamp in UserDefaults and Firebase DB
                                if maxTimestamp > currentExpiryTimestamp{
                                    UserDefaults.standard.set(maxTimestamp, forKey: "expiryTimestamp")
                                    self.setExpiryTimestamp(timestamp: maxTimestamp)
                                }
                                
                            default:
                                break
                            }
                            
                            
                        } else {
                            // receipt verification error
                            
                        }
                    }
                    //------------------------------------------------------------------
                }
 */
            }
            
            
        }
        
        
    }
    // IAP 6
    func setExpiryTimestamp(timestamp:Double){
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        FirebaseUtil.shared.setExpiryTimestamp(userId: myUserId, expiryTimestamp: timestamp) { (error) in
            if error != nil{
                print(">>>Failed to set expiryTimestamp from AppDelegate. Error: \(String(describing: error?.localizedDescription))")
                self.setExpiryTimestamp(timestamp:timestamp)
            }else{
                print(">>>Success to set expiryTimestamp from AppDelegate")
            }
        }
    }
    
    // IAP 5
    // Called for athletes
    // If the subscribe is expired, verify subscription to update the expiry timestamp in UserDefaults and Firebase DB
    func updateExpiryTimestamp(){
        // Return unless the user is logged in and has got expiryTimestamp from Firebase DB.
        guard let temp = UserDefaults.standard.object(forKey: "expiryTimestamp") else {return}
        var expiryTimestamp = temp as! Double
        
        let appleValidator = AppleReceiptValidator(service: .production)
        let productIdMonth = Bundle.main.bundleIdentifier! + "." + SubscriptionType.OneMonthOfBasicPlus.rawValue
        let productIdYear = Bundle.main.bundleIdentifier! + "." + SubscriptionType.OneYearOfBasicPlus.rawValue
       
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: sharedSecrets) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a monthly Subscription
                let purchaseResultMonth = SwiftyStoreKit.verifySubscription(
                    type: .autoRenewable, // or .nonRenewing (see below)
                    productId: productIdMonth,
                    inReceipt: receipt)
                
                switch purchaseResultMonth {
                case .purchased(let expiryDate, let receiptItems):
                    print("Product is valid until \(expiryDate)")
                    let timestamp = expiryDate.timeIntervalSince1970
                    if timestamp > expiryTimestamp{ // Update the expiry timestamp
                        self.setExpiryTimestamp(timestamp: timestamp)
                        UserDefaults.standard.set(timestamp, forKey: "expiryTimestamp")
                        expiryTimestamp = timestamp
                    }
                case .expired(let expiryDate, let receiptItems):
                    print("Product is expired since \(expiryDate)")
                case .notPurchased:
                    print("The user has never purchased this product")
                }
                
                
                // Verify the purchase of a yearly Subscription
                let purchaseResultYear = SwiftyStoreKit.verifySubscription(
                    type: .autoRenewable, // or .nonRenewing (see below)
                    productId: productIdYear,
                    inReceipt: receipt)
                
                switch purchaseResultYear {
                case .purchased(let expiryDate, let receiptItems):
                    print("Product is valid until \(expiryDate)")
                    let timestamp = expiryDate.timeIntervalSince1970
                    if timestamp > expiryTimestamp{ // Update the expiry timestamp
                        self.setExpiryTimestamp(timestamp: timestamp)
                        UserDefaults.standard.set(timestamp, forKey: "expiryTimestamp")
                        expiryTimestamp = timestamp
                    }
                case .expired(let expiryDate, let receiptItems):
                    print("Product is expired since \(expiryDate)")
                case .notPurchased:
                    print("The user has never purchased this product")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    func setInitialVC(){
        
        // Go to AthleteNewsVC if logged in
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if isLoggedIn == true{
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NavViewController")
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
        }else{
            // Go to ViewController if not logged in
            self.window = UIWindow(frame: UIScreen.main.bounds)            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        /*
        if Auth.auth().currentUser != nil {
            
            // If first launch, sign out to log in again
            if UserDefaults.standard.value(forKey: "launched") == nil {
                do {
                    try Auth.auth().signOut()
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }else{
                let userType = UserDefaults.standard.value(forKey: "userType") as! String
                // If not a coach, show AthleteNewsVC
                // Otherwise check if the coach is verified
                if userType == UserType.athlete.rawValue || userType == UserType.proAthlete.rawValue || userType == UserType.fan.rawValue{
                    
                    let vc = storyboard.instantiateViewController(withIdentifier: "NavViewController")
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                }else{
                    let state = UserDefaults.standard.string(forKey: "state")
                    if state == "verified" {
                        let vc = storyboard.instantiateViewController(withIdentifier: "NavViewController")
                        self.window?.rootViewController = vc
                        self.window?.makeKeyAndVisible()

                    }
                }
            }
            
        }
        
        // Set lauched
        UserDefaults.standard.set("launched", forKey: "launched")
        UserDefaults.standard.synchronize()
 */
    }
    
    //----------------------------- Delegate methods for OneSignal --------------------------------
    // Add this new method
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        // prints out all properties
        print("PermissionStateChanges: \n\(stateChanges)")
    }
    
    // Output:
    /*
     Thanks for accepting notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSPermissionState: hasPrompted: 0, status: NotDetermined>,
     to:   <OSPermissionState: hasPrompted: 1, status: Authorized>
     >
     */
    
    // TODO: update docs to change method name
    // Add this new method
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
            
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
        
        // Upload OneSignal userId to Firebase DB
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        guard let oneSignalUserId = status.subscriptionStatus.userId else{return}
        FirebaseUtil.shared.uploadOneSignalUserId(userId: oneSignalUserId) { (error) in
            if error != nil{
                print(">>>Failed to upload OneSignal userId")
            }else{
                print(">>>Success to upload OneSignal userId")
            }
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(oneSignalUserId, forKey: "oneSignalUserId")
    }
    
    // Output:
    
    /*
     Subscribed for OneSignal push notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSSubscriptionState: userId: (null), pushToken: 0000000000000000000000000000000000000000000000000000000000000000 userSubscriptionSetting: 1, subscribed: 0>,
     to:   <OSSubscriptionState: userId: 11111111-222-333-444-555555555555, pushToken: 0000000000000000000000000000000000000000000000000000000000000000, userSubscriptionSetting: 1, subscribed: 1>
     >
     */
    //-------------------------------------------------------------
    
    
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> ()) {
        
       // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print(">>>Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
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
//        self.updateExpiryTimestamp()
//        self.restorePurchase()
        
    }
    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.yl.Genuis_Capture" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "TinderForHome", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]


extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print(">>>Firebase registration token: \(fcmToken)")
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(">>>Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}



