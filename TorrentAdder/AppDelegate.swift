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
    
    static var obtain: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow? // TODO: delete when we'll have removed SVProgressHUD
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        HostnameResolver.shared.start()

        SVProgressHUD.setBackgroundColor(.accent)
        SVProgressHUD.setForegroundColor(.textOverAccent)

        return true
    }
}
