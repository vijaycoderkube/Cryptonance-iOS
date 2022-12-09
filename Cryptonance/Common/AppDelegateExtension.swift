//
//  AppDelegateExtension.swift
//  Cryptonance
//
//  Created by iMac on 09/11/22.
//

import Foundation
import UserNotifications
import UserNotificationsUI
import FirebaseMessaging
import Firebase
import SwiftyJSON
import FirebaseDatabase

@available(iOS 13.0, *)
extension AppDelegate {
    
    func firebaseValueChanged(){
        let phoneNumber = Config().userData().string(key:"phoneNumber")
        if phoneNumber.trimmingLeadingAndTrailingSpaces() != "" {
            databseReference.child("user").child(phoneNumber).observe(.childChanged, with: { (snapshot) -> Void in
                print("user1........................................")
                databseReference.child("user").child(phoneNumber).getData(completion:  { error, snapshot in
                    guard error == nil else
                    {
                        print(error!.localizedDescription)
                        return;
                    }
                    print("user2........................................")
                    let object = snapshot?.value as? JSONDictionary
                    if ((object?.keys.contains(phoneNumber)) != nil) {
                        userDataObject = object ?? [:]
                        userDataObject["phoneNumber"] = phoneNumber as AnyObject
                        Config().saveUserData(Object: userDataObject)
                        self.rootToController()
                    }
                })
            })
        }
    }
    
    func firebaseValueRemoved() {
        let phoneNumber = Config().userData().string(key:"phoneNumber")
        if phoneNumber.trimmingLeadingAndTrailingSpaces() != "" {
            databseReference.child("user").child(phoneNumber).observe(.childRemoved, with: { (snapshot) -> Void in
                print("Child Removed.......")
                
                DispatchQueue.main.async {
                    self.window?.rootViewController?.showAlert(title: "APP_TITLE".localized, msg: "YOU_HAVE_BEEN_LOGGED_OUT".localized, alertOkTitle: "OK".localized, okHandlor: {
                        let MainViewController = AppNavigationController(rootViewController: HomeScreenViewController())
                        self.window?.rootViewController = MainViewController
                        UserDefaults.standard.removeObject(forKey: "profile")
                    }, cancelTitle: "", showCancelButton: false)
                }
            })
        }
    }
    
    func rootToController(){
        if Config().userData()["identityVerified"] == false && Config().userData()["accountCreated"] == true{
            let MainViewController = AppNavigationController(rootViewController: StepsViewController())
            self.window?.rootViewController = MainViewController
            
        } else if (Config().userData()["identityVerified"] == true) && (Config().userData()["wantToSell"] == false) && (Config().userData()["wantToBuy"] == false) {
            let MainViewController = AppNavigationController(rootViewController: StepsViewController())
            self.window?.rootViewController = MainViewController
            
        } else if (Config().userData()["identityVerified"] == true) && ((Config().userData()["wantToSell"] == true) || (Config().userData()["wantToBuy"] == true)) {
            let MainViewController = AppNavigationController(rootViewController: DashboardViewController())
            self.window?.rootViewController = MainViewController
            
        } else if Config().userData()["accountCreated"] == false {
            let MainViewController = AppNavigationController(rootViewController: HomeScreenViewController())
            self.window?.rootViewController = MainViewController
            
        } else {
            let MainViewController = AppNavigationController(rootViewController: HomeScreenViewController())
            self.window?.rootViewController = MainViewController
        }
        self.window?.makeKeyAndVisible()
    }
}

@available(iOS 13.0, *)
extension AppDelegate {
    func changeLanguage(_ languageCode: String) {
        var setLanguageCode: String = ""
        
        if let arr = (UserDefaults.standard.object(forKey: APPLE_LANGUAGE) as? [String]) {
            print("Language....\(languageCode)")
            setLanguageCode = languageCode
            if arr[0] == languageCode { return }
        }
        
        UserDefaults.standard.set([languageCode], forKey: APPLE_LANGUAGE)
        UserDefaults.standard.synchronize()
        
        //Run time conversion if you want
        Bundle.setLanguages(languageCode)
        UserDefaults.standard.synchronize()
    }
}

@available(iOS 13.0, *)
extension AppDelegate : UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        ///-- Notification remove
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("deviceToken:-",token)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func registerForFirebaseNotification(application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        //        firebaseFCMToken = fcmToken ?? ""
        let userfield = UserDefaults.standard
        userfield.set(fcmToken, forKey: "FcmToken")
        userfield.synchronize()
        Config.fcmToken = fcmToken ?? ""
        print("Firebase FCM token :- \(fcmToken ?? "")")
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register for notifications:- \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let dict = JSON(userInfo)
        NotificationCenter.default.post(name: NSNotification.Name("com.user.push"), object: dict)
        
        print("APNs received with:- \(dict)")
        
        if let body = dict["body"].string {
            let bodyToJson = JSON(body.toJSON() as Any)
            print("Body Response:- \(bodyToJson)")
            dictNotification = bodyToJson
            completionHandler(.newData)
        }
    }
    
    //Application foreground selected
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let dict = JSON(response.notification.request.content.userInfo)
        NotificationCenter.default.post(name : NSNotification.Name("com.user.push"), object : dict)
        print("didReceive:- \(dict)")
        
        if let body = dict["body"].string {
            let bodyToJson = JSON(dict as Any)
            print("Body Response:- \(bodyToJson)")
            
            dictNotification = bodyToJson
        }
        completionHandler()
    }
    
    //Notification gate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let dict = JSON(notification.request.content.userInfo)
        print("willPresent:- \(dict)")
        
        if let body = dict["body"].string {
            let bodyToJson = JSON(body.toJSON() as Any)
            print("Body Response:- \(bodyToJson)")
            let dataToJson = JSON(bodyToJson["data"].stringValue.toJSON() as Any)
            print("Data Response:- \(dataToJson)")
        }
        completionHandler([.alert, .badge, .sound])
    }
}

@available(iOS 13.0, *)
extension AppDelegate {
    
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
            return window
        }
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }
}
