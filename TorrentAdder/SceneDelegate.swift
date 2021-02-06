//
//  SceneDelegate.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 23/09/2020.
//  Copyright © 2020 Syan. All rights reserved.
//

import UIKit
import SYKit

class SceneDelegate: UIResponder {
    @available(iOS 13.0, *)
    static func createWindow(windowScene: UIWindowScene) -> UIWindow {
        let mainVC = MainVC()
        mainVC.loadViewIfNeeded() // make sure the didOpenURL notification is properly registered before continuing
        let nc = NavigationController(rootViewController: mainVC)

        let window = SYWindow.mainWindow(windowScene: windowScene, rootViewController: nc)
        #if DEBUG
        (window as? SYWindow)?.enableSlowAnimationsOnShake = true
        #endif
        return window
    }

    static func createWindow() -> UIWindow {
        let mainVC = MainVC()
        mainVC.loadViewIfNeeded() // make sure the didOpenURL notification is properly registered before continuing
        let nc = NavigationController(rootViewController: mainVC)

        let window = SYWindow.mainWindow(rootViewController: nc)
        #if DEBUG
        (window as? SYWindow)?.enableSlowAnimationsOnShake = true
        #endif
        return window
    }

    var window: UIWindow?
}

@available(iOS 13.0, *)
extension SceneDelegate : UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
        if let windowScene = scene as? UIWindowScene {
            self.window = SceneDelegate.createWindow(windowScene: windowScene)
            
            // temporary fix for SVProgressHUD
            (UIApplication.shared.delegate as? AppDelegate)?.window = window

            #if targetEnvironment(macCatalyst)
            if let titlebar = windowScene.titlebar {
                titlebar.titleVisibility = .hidden
                titlebar.toolbar = nil
            }
            #endif
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let magnetURL = URLContexts.map(\.url).first(where: { $0.scheme == "magnet" }) else { return }
        ViewRouter.shared.handleOpenedURL(magnetURL, window: window)
    }
}
