//
//  AppDelegate.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 21/10/22.
//

import UIKit
import FirebaseCore
import IQKeyboardManagerSwift
import FirebaseMessaging
import Firebase

@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Thread.sleep(forTimeInterval: 3.0)
        
        ///... Key bord manager extenstion for manage keybord events.
        IQKeyboardManager.shared.enable = true
        
        //Firebase setup
        FirebaseApp.configure()
        firebaseValueChanged()
        firebaseValueRemoved()
        UNUserNotificationCenter.current().delegate = self
        self.registerForFirebaseNotification(application: application)
        Messaging.messaging().delegate = self
        
        //Firebase message token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                
                let userfield = UserDefaults.standard
                userfield.set(token, forKey: "FcmToken")
                userfield.synchronize()
                Config.fcmToken = token
                if UserDefaults.standard.value(forKey: "token") != nil && (UserDefaults.standard.value(forKey: "token")) as? String != "" {
                    //MARK:- Update the fcm token
                }
            }
        }
        application.registerForRemoteNotifications()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


private var kBundleKey: UInt8 = 0
class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &kBundleKey) {
            return (bundle as! Bundle).localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

private var kBundleUIKitKey: UInt8 = 0
class BundleUIKitEx: Bundle {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &kBundleUIKitKey) {
            return (bundle as! Bundle).localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

//Lang changes code
extension Bundle {
    
    static let once: Void = {
        object_setClass(Bundle.main, type(of: BundleEx()))
        object_setClass(Bundle(identifier:"com.apple.UIKit"), type(of: BundleUIKitEx()))
    }()
    
    class func setLanguages(_ language: String?) {
        Bundle.once
        UserDefaults.standard.synchronize()
        
        let value = (language != nil ? Bundle.init(path: (Bundle.main.path(forResource: language, ofType: "lproj"))!) : nil)
        objc_setAssociatedObject(Bundle.main, &kBundleKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if let uiKitBundle = Bundle(identifier: "com.apple.UIKit") {
            var valueUIKit: Bundle? = nil
            if let lang = language,
               let path = uiKitBundle.path(forResource: lang, ofType: "lproj") {
                valueUIKit = Bundle(path: path)
            }
            objc_setAssociatedObject(uiKitBundle, &kBundleUIKitKey, valueUIKit, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}
