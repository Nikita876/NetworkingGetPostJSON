//
//  AppDelegate.swift
//  NetworkingGetPostJSON
//
//  Created by Никита Коголенок on 21.04.21.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

let primaryColor = UIColor(red: 210/255, green: 109/255, blue: 128/255, alpha: 1)
let secondaryColor = UIColor(red: 107/255, green: 148/255, blue: 230/255, alpha: 1)

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var backgroundSessionCompletionHandler: (() -> ())?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        /*
        let appId = Settings.appID
        
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId)") && url.host ==  "authorize" {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        */
        return GIDSignIn.sharedInstance().handle(url)
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        backgroundSessionCompletionHandler = completionHandler
    }
}
