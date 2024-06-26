//
//  UIViewController+SY.swift
//  Magneto
//
//  Created by syan on 18/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
    func openSafariURL(_ url: URL) {
        #if targetEnvironment(macCatalyst)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        #elseif os(iOS)
        let vc = SFSafariViewController(url: url)
        vc.preferredBarTintColor = UIColor.tint.resolvedColor(with: traitCollection)
        vc.preferredControlTintColor = UIColor.normalText.resolvedColor(with: traitCollection)
        present(vc, animated: true, completion: nil)
        #endif
    }
    
    func openTorrentPopup(with source: MagnetPopupVC.Source, sender: UIView?) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) {
                self.openTorrentPopup(with: source, sender: sender)
            }
            return
        }
        
        MagnetPopupVC.show(in: self, source: source, sender: sender)
    }
}
