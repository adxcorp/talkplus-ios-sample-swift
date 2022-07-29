//
//  AppDelegate.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/06.
//

import UIKit
import TalkPlus

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TalkPlus.sharedInstance()?.initWithAppId("875bd0c3-83eb-4086-b7ba-a1a8b05a26fe")
        //PushManager.shared.registerForRemoteNotifications(application)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let payload = userInfo["talkplus"] as? String {
            TalkPlus.sharedInstance().handleFCMMessage(payload)
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
}
