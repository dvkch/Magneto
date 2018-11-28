//
//  SYSourceApp.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

enum SYSourceApp {
    case safari, mail, sms, chrome, opera, dolphin, mailbox
    
    // TODO: keep? did status bar back button appear at iOS 9?
    var launchURL: URL? {
        let selfClosingPage = "rawgit.com/dvkch/TorrentAdder/master/self_closing_page.html"
        let urlString: String
        switch self {
        case .safari:   urlString = "https://" + selfClosingPage    // opens new page
        case .mail:     urlString = "mailto://"                     // opens empty composer
        case .sms:      urlString = "sms://"                        // opens empty composer
        case .chrome:   urlString = "googlechrome://"               // OK
        case .dolphin:  urlString = "dolphin://"                    // OK
        case .opera:    urlString = "ohttps://" + selfClosingPage   // opens new page
        case .mailbox:  urlString = "dbx-mailbox://"                // OK
        }
        return URL(string: urlString)
    }
    
    init?(bundleId: String?) {
        guard let bundleId = bundleId else { return nil }
        switch bundleId {
        case "com.apple.mobilesafari":      self = .safari
        case "com.apple.mobilemail":        self = .mail
        case "com.apple.mobilesms":         self = .sms
        case "com.google.chrome.ios":       self = .chrome
        case "com.dolphin.browser.iphone":  self = .dolphin
        case "com.opera.OperaMini":         self = .opera
        case "com.orchestra.v2":            self = .mailbox
        default: return nil
        }
    }
}
