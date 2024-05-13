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
        
        return true
    }
    
    private func updateObservedHosts() {
        HostStatusManager.shared.hosts = Preferences.shared.clients.map { .init(host: $0.host, port: $0.portOrDefault) }
    }
}
