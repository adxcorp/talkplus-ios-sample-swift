//
//  PushManager.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/08/09.
//

import Firebase
import FirebaseMessaging
import TalkPlus

class PushManager: NSObject {
    static let shared = PushManager()
    
    func registerForRemoteNotifications(_ application: UIApplication) {
        FirebaseApp.configure()

        let center = UNUserNotificationCenter.current();
        center.delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: authOptions) { (result, error) in }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
    }
    
    func registerFCMToken() {
        Messaging.messaging().token { token, error in
            if let fcmToken = token {
                print("fcmtoken: \(fcmToken)")
                
                TalkPlus.sharedInstance().registerFCMToken(fcmToken) {
                    print("fcmToken register success");
                    
                } failure: { errorCode, error in
                    print("fcmToken register failure");
                }
            }
        }
    }
}

extension PushManager: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            print("fcmtoken: \(fcmToken)")
        }
    }
}
