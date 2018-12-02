//
//  AppDelegate.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit
import JiveAuthenticatingHTTPProtocol

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
    
    var window: SYWindow?
    var isShowingAuthAlertView: Bool = false

    static var obtain: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SYHostnameResolver.shared.start()
        
        JAHPAuthenticatingHTTPProtocol.setDelegate(self)
        JAHPAuthenticatingHTTPProtocol.start()
        
        let vc = SYMainVC()
        let nc = SYNavigationController(rootViewController: vc)
        window = SYWindow.mainWindow(withRootViewController: nc)
        window?.preventSlowAnimationsOnShake = false
        
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
}


// MARK: JAHPAuthenticatingHTTPProtocolDelegate

extension AppDelegate : JAHPAuthenticatingHTTPProtocolDelegate {
    func authenticatingHTTPProtocol(_ authenticatingHTTPProtocol: JAHPAuthenticatingHTTPProtocol, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace) -> Bool {
        return protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic
    }
    
    func authenticatingHTTPProtocol(_ authenticatingHTTPProtocol: JAHPAuthenticatingHTTPProtocol, didReceive challenge: URLAuthenticationChallenge) -> JAHPDidCancelAuthenticationChallengeHandler? {
        
        guard let request = authenticatingHTTPProtocol.request as? NSMutableURLRequest,
            let computerID = request.computerID,
            let computer = SYDatabase.shared.computer(withID: computerID) else {

            authenticatingHTTPProtocol.cancelPendingAuthenticationChallenge()
            return nil
        }
        
        request.numberOfAuthTries += 1;
        
        if (request.numberOfAuthTries < 2)
        {
            let credential = URLCredential(user: computer.username, password: computer.password, persistence: .forSession)
            authenticatingHTTPProtocol.resolvePendingAuthenticationChallenge(with: credential)
            return nil;
        }
        
        if isShowingAuthAlertView {
            authenticatingHTTPProtocol.cancelPendingAuthenticationChallenge()
            return nil
        }
        
        var canceled = false
        
        let alert = UIAlertController(title: "Authentication needed", message: String(format: "%@ requires a user and a password", computer.name), preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Username"
            if #available(iOS 11.0, *) {
                field.textContentType = .username
            }
        }
        alert.addTextField { field in
            field.placeholder = "Password"
            if #available(iOS 11.0, *) {
                field.textContentType = .password
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.isShowingAuthAlertView = false
            if canceled {
                return
            }
            authenticatingHTTPProtocol.cancelPendingAuthenticationChallenge()
        }))
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in
            computer.username = alert.textFields?.first?.text
            computer.password = alert.textFields?.last?.text
            SYDatabase.shared.addComputer(computer)
            if canceled {
                return
            }
            let credential = URLCredential(user: computer.username, password: computer.password, persistence: .forSession)
            authenticatingHTTPProtocol.resolvePendingAuthenticationChallenge(with: credential)
        }))
        
        isShowingAuthAlertView = true
        window?.rootViewController?.present(alert, animated: true, completion: nil)
        
        return { _, _ in
            canceled = true
        }
    }
}
/*
    - (nullable JAHPDidCancelAuthenticationChallengeHandler)authenticatingHTTPProtocol:(nonnull JAHPAuthenticatingHTTPProtocol *)authenticatingHTTPProtocol
didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge
{
}

/*
 - (void)authenticatingHTTPProtocol:(nullable JAHPAuthenticatingHTTPProtocol *)authenticatingHTTPProtocol logWithFormat:(nonnull NSString *)format
 arguments:(va_list)arguments
 {
 NSLog(@"%@", [[NSString alloc] initWithFormat:format arguments:arguments]);
 }
 */

@end
*/
