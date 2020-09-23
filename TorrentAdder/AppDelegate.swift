//
//  AppDelegate.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    @objc var window: UIWindow?

    static var obtain: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        HostnameResolver.shared.start()

        SVProgressHUD.setBackgroundColor(.accent)
        SVProgressHUD.setForegroundColor(.textOverAccent)

        if #available(iOS 13.0, *) {} else {
            window = SceneDelegate.createWindow()
        }
        
        #if os(iOS)
        ViewRouter.shared.handleUpdateCheck()
        #endif

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ViewRouter.shared.handleOpenedURL(url, window: window)
        return true
    }
}
