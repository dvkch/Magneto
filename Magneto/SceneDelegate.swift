//
//  SceneDelegate.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 23/09/2020.
//  Copyright © 2020 Syan. All rights reserved.
//

import UIKit
import SYKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    private var window: SYWindow?
    
    lazy var mainVC = MainVC()
    private lazy var navigationController = NavigationController(rootViewController: mainVC)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = SYWindow.mainWindow(windowScene: windowScene, rootViewController: navigationController)
        #if DEBUG
        window?.enableSlowAnimationsOnShake = true
        #endif

        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif
        
        DispatchQueue.main.async {
            // surprisingly not done automatically ¯\_(ツ)_/¯
            self.scene(scene, openURLContexts: connectionOptions.urlContexts)
            
            // check updates
            ViewRouter.shared.handleUpdateCheck(in: windowScene)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let magnetURL = URLContexts.map(\.url).first(where: { $0.scheme == "magnet" }) else { return }
        mainVC.loadViewIfNeeded()
        mainVC.openTorrentPopup(with: .resolved(.url(magnetURL)), sender: nil)
    }
}
