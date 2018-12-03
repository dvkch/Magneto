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

extension Notification.Name {
    static let didOpenURL = Notification.Name(rawValue: "UIAppDidOpenURLNotification")
}

extension UIApplication {
    enum DidOpenURLKey: String, Hashable {
        case appID, magnetURL
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    @objc var window: UIWindow?
    var isShowingAuthAlertView: Bool = false

    static var obtain: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SYHostnameResolver.shared.start()
        
        SVProgressHUD.setBackgroundColor(.lightBlue)
        SVProgressHUD.setForegroundColor(.white)
        
        let vc = SYMainVC()
        let nc = SYNavigationController(rootViewController: vc)
        window = SYWindow.mainWindow(withRootViewController: nc)
        (window as? SYWindow)?.preventSlowAnimationsOnShake = false
        
        #if DEBUG_POPUP
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let magnet = "magnet:?xt=urn:btih:0403fb4728bd788fbcb67e87d6feb241ef38c75a&dn=ubuntu-16.10-desktop-amd64.iso&tr=http%3A%2F%2Ftorrent.ubuntu.com%3A6969%2Fannounce&tr=http%3A%2F%2Fipv6.torrent.ubuntu.com%3A6969%2Fannounce"
            
            NotificationCenter.default.post(name: .didOpenURL, object: nil, userInfo: [UIApplication.DidOpenURLKey.magnetURL: URL(string: magnet)!])
        }
        #endif
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var userInfo: [UIApplication.DidOpenURLKey: Any] = [
            UIApplication.DidOpenURLKey.magnetURL: url,
        ]
        
        if let source = options[.sourceApplication]  {
            userInfo[UIApplication.DidOpenURLKey.appID] = source
        }
        
        NotificationCenter.default.post(name: .didOpenURL, object: nil, userInfo: userInfo)
        return true
    }
}

// MARK: Public methods
extension AppDelegate {
    func openApp(_ app: SYSourceApp?) {
        guard let url = app?.launchURL else { return }
        UIApplication.shared.openURL(url)
    }
    
    var topViewController: UIViewController? {
        var viewController = window?.rootViewController
        while true {
            if let nc = viewController as? UINavigationController {
                viewController = nc.viewControllers.last
            }
            else if let tc = viewController as? UITabBarController {
                viewController = tc.selectedViewController
            }
            else if let pc = viewController?.presentedViewController {
                viewController = pc
            }
            else {
                break
            }
        }
        return viewController
    }
}

// MARK: Authentication
extension AppDelegate {
    func promptAuthenticationUpdate(for client: SYClient, completion: @escaping (_ cancelled: Bool) -> Void) {
        if isShowingAuthAlertView {
            completion(true)
            return
        }
        
        isShowingAuthAlertView = true
        
        let alert = UIAlertController(
            title: "Authentication needed",
            message: String(format: "%@ requires a user and a password", client.name ?? client.host),
            preferredStyle: .alert
        )
        
        alert.addTextField { field in
            field.placeholder = "Username"
            if #available(iOS 11.0, *) {
                field.textContentType = .username
            }
        }
        
        alert.addTextField { field in
            field.placeholder = "Password"
            field.isSecureTextEntry = true
            if #available(iOS 11.0, *) {
                field.textContentType = .password
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.isShowingAuthAlertView = false
            completion(true)
        }))
        
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in
            client.username = alert.textFields?.first?.text
            client.password = alert.textFields?.last?.text
            SYPreferences.shared.addClient(client)
            self.isShowingAuthAlertView = false
            completion(false)
        }))
        
        topViewController?.present(alert, animated: true, completion: nil)
    }
}
