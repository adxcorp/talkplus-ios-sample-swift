//
//  AppDelegate.swift
//  TalkPlusSampleSwift
//
//  Created by hnroh on 2021/01/06.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TalkPlus.sharedInstance()?.initWithAppId("875bd0c3-83eb-4086-b7ba-a1a8b05a26fe")
        
        return true
    }
}

