//
//  ViewRouter.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 23/09/2020.
//  Copyright © 2020 Syan. All rights reserved.
//

import UIKit

class ViewRouter {
    
    // MARK: Init
    static let shared = ViewRouter()
    
    private init() {
    }
    
    // MARK: Properties
    private var isShowingAuthAlertView: Bool = false

    // MARK: Finding views
    private func mainVC(in scene: UIWindowScene) -> MainVC? {
        guard let delegate = scene.delegate as? SceneDelegate else { return nil }
        return delegate.mainVC
    }
    
    private func topViewController(in scene: UIWindowScene) -> UIViewController? {
        var viewController = scene.windows.first(where: \.isKeyWindow)?.rootViewController
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
    
    // MARK: Routes
    func handleUpdateCheck(in scene: UIWindowScene) {
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
                self.mainVC(in: scene)?.present(alert, animated: true, completion: nil)
            }
            .onFailure { (error) in
                print("Couldn't download dist plist:", error)
            }
    }
    
    func promptAuthenticationUpdate(for client: Client, completion: @escaping (_ cancelled: Bool) -> Void) {
        guard let scene: UIWindowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else { return }

        if isShowingAuthAlertView {
            completion(true)
            return
        }
        
        isShowingAuthAlertView = true
        
        let alert = UIAlertController(
            title: "alert.auth.title".localized,
            message: "alert.auth.message %@".localized(client.name),
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
        
        topViewController(in: scene)?.present(alert, animated: true, completion: nil)
    }
}
