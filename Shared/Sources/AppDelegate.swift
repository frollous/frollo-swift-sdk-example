//
//  AppDelegate.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 26/6/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import UIKit

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute
import FrolloSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var flowManager: FlowManager?
    var window: UIWindow?
    
    private let appCenterID = "d954b866-6110-433a-9b91-16b7b48b33d3"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        flowManager = FlowManager(window: window!)
        
        setupAppCenter()
        
        let startupViewController = window?.rootViewController as! StartupViewController
        startupViewController.flowManager = flowManager
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Frollo.shared.applicationDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Frollo.shared.applicationWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Frollo.shared.notifications.registerPushNotificationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Frollo.shared.notifications.handlePushNotification(userInfo: userInfo)
        
        completionHandler(.newData)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "frollo-sdk-example" {
            return Frollo.shared.oAuth2Authentication?.resumeAuthentication(url: url) ?? false
        } else {
            // Handle AppCenter auth
            return MSDistribute.open(url)
        }
    }
    
    // MARK: - AppCenter
    
    private func setupAppCenter() {
        #if DEBUG
        MSAppCenter.start(appCenterID, withServices: [MSAnalytics.self, MSCrashes.self])
        #else
        MSAppCenter.start(appCenterID, withServices: [MSAnalytics.self, MSCrashes.self, MSDistribute.self])
        MSDistribute.setEnabled(true)
        #endif
    }

}

