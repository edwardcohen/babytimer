//
//  AppDelegate.swift
//  BabyTimer
//
//  Created by Eddie Cohen & Jason Toff on 7/20/16.
//  Copyright © 2016 zelig. All rights reserved.
//

import UIKit
import Appsee

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var shortcutItem: UIApplicationShortcutItem?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        BuddyBuildSDK.setup()
        Appsee.start("580faca6704d44b6815c5985a3c96f62")
        
        var performShortcutDelegate = true
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
            
            performShortcutDelegate = false
        }

        return performShortcutDelegate
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        print("Application did become active")
        
        guard let shortcut = shortcutItem else { return }
        
        print("- Shortcut property has been set")
        
        handleShortcut(shortcut)
        
        self.shortcutItem = nil
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var succeeded = false
        
        if shortcutItem.type == (NSBundle.mainBundle().bundleIdentifier!+".FiveMinutes") {
            print("- Handling \(shortcutItem.type)")
            let viewController = self.window!.rootViewController as! ViewController
            if !viewController.brightMoon { viewController.updateState() }
            viewController.timerAction(5)
            succeeded = true
        } else if shortcutItem.type == (NSBundle.mainBundle().bundleIdentifier!+".FifteenMinutes") {
            print("- Handling \(shortcutItem.type)")
            let viewController = self.window!.rootViewController as! ViewController
            if !viewController.brightMoon { viewController.updateState() }
            viewController.timerAction(15)
            succeeded = true
        }
        
        return succeeded
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }


}

