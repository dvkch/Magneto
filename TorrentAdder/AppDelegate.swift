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

// TODO: add search history
// TODO: replace SYPopover by real popover ?

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
    private let mainVC = MainVC()

    static var obtain: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        HostnameResolver.shared.start()
        
        SVProgressHUD.setBackgroundColor(.accent)
        SVProgressHUD.setForegroundColor(.textOverAccent)

        let nc = NavigationController(rootViewController: mainVC)
        window = SYWindow.mainWindow(rootViewController: nc)
        #if DEBUG
        (window as? SYWindow)?.enableSlowAnimationsOnShake = true
        #endif
        
        #if DEBUG_POPUP
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let magnet = "magnet:?xt=urn:btih:0403fb4728bd788fbcb67e87d6feb241ef38c75a&dn=ubuntu-16.10-desktop-amd64.iso&tr=http%3A%2F%2Ftorrent.ubuntu.com%3A6969%2Fannounce&tr=http%3A%2F%2Fipv6.torrent.ubuntu.com%3A6969%2Fannounce"
            
            NotificationCenter.default.post(name: .didOpenURL, object: nil, userInfo: [UIApplication.DidOpenURLKey.magnetURL: URL(string: magnet)!])
        }
        #endif
        
        mainVC.loadViewIfNeeded() // make sure the didOpenURL notification is properly registered before continuing
        
        #if os(iOS)
        checkUpdates()
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

// MARK: Update
extension AppDelegate {
    private func checkUpdates() {
        let currentBuild = Int(Bundle.main.buildVersion) ?? 0
        WebAPI.shared.getLatestBuildNumber()
            .onSuccess { (value) in
                guard let distBuildNumber = value else { return }
                guard distBuildNumber > currentBuild else { return }
                
                let alert = UIAlertController(title: "alert.update.title".localized, message: "alert.update.message".localized, preferredStyle: .alert)
                alert.addAction(title: "action.update".localized, style: .default) { _ in
                    UIApplication.shared.open(URL(string: "https://ota.syan.me/")!, options: [:], completionHandler: nil)
                }
                alert.addAction(title: "action.cancel".localized, style: .cancel, handler: nil)
                self.mainVC.present(alert, animated: true, completion: nil)
            }
            .onFailure { (error) in
                print("Couldn't download dist plist:", error)
            }
    }

}

// MARK: Public methods
extension AppDelegate {
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
    func promptAuthenticationUpdate(for client: Client, completion: @escaping (_ cancelled: Bool) -> Void) {
        if isShowingAuthAlertView {
            completion(true)
            return
        }
        
        isShowingAuthAlertView = true
        
        let alert = UIAlertController(
            title: "alert.auth.title".localized,
            message: String(format: "alert.auth.message %@".localized, client.name ?? client.host),
            preferredStyle: .alert
        )
        
        alert.addTextField { field in
            field.placeholder = "client.username".localized
            if #available(iOS 11.0, *) {
                field.textContentType = .username
            }
        }
        
        alert.addTextField { field in
            field.placeholder = "client.password".localized
            field.isSecureTextEntry = true
            if #available(iOS 11.0, *) {
                field.textContentType = .password
            }
        }
        
        alert.addAction(title: "action.cancel".localized, style: .cancel) { (_) in
            self.isShowingAuthAlertView = false
            completion(true)
        }
        
        alert.addAction(title: "action.login".localized, style: .default) { (_) in
            client.username = alert.textFields?.first?.text
            client.password = alert.textFields?.last?.text
            Preferences.shared.addClient(client)
            self.isShowingAuthAlertView = false
            completion(false)
        }
        
        topViewController?.present(alert, animated: true, completion: nil)
    }
}
