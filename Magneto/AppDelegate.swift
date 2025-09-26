//
//  AppDelegate.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit
import Disco
import Network
import BrightFutures
import WebKit

// TODO: pull data from Hapier, if it errors with a 'server not found' then try locally (or the opposite?)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var obtain: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        HostnameResolver.shared.start()

        HostStatusManager.shared.start()
        self.updateObservedHosts()
        NotificationCenter.default.addObserver(forName: .clientsChanged, object: nil, queue: .main) { _ in
            self.updateObservedHosts()
        }
        
        NWConnection.askLocalNetworkAccess({ _ in () })

        #if DEBUG
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          dataStore.removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            for: records,
            completionHandler: {}
          )
        }
        #endif

        return true
    }
    
    private func updateObservedHosts() {
        HostStatusManager.shared.hosts = Preferences.shared.clients.map { .init(host: $0.host, port: $0.portOrDefault) }
    }
    
    func loadPageContentUsingWebKit(_ url: URL) -> Future<String, AppError> {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init(error: .noAvailableAPI)
        }
        guard let sceneDelegate = scene.delegate as? SceneDelegate else {
            return .init(error: .noAvailableAPI)
        }

        return .init { resolver in
            let vc = ChallengeVC(url: url) { result in
                resolver(result)
            }
            let nc = NavigationController()
            nc.navbarBackgroundColor = .tint
            nc.viewControllers = [vc]
            nc.modalPresentationStyle = .formSheet
            sceneDelegate.mainVC.present(nc, animated: true)
        }
    }
}
