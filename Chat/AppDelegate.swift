//
//  AppDelegate.swift
//  Chat
//
//  Created by  mac on 1/29/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.shared.enableAutoToolbar = false 
        IQKeyboardManager.shared.enable = true // just add this line
        
        //FB
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Google
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        if url.absoluteString.contains("fb") {
            let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        else {
            handled = GIDSignIn.sharedInstance()!.handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
            
        }
        return handled
        
        
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

