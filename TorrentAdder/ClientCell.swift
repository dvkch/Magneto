//
//  ClientCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class ClientCell: UITableViewCell {
    
    // MARK: Init
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: .clientStatusChanged, object: nil)
        activityIndicator.color = .text
        nameLabel.textColor = .text
        hostLabel.textColor = .subtext
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .clientStatusChanged, object: nil)
    }
    
    // MARK: Properties
    var kind: Kind = .client(nil) {
        didSet {
            updateContent()
            updateStatus()
        }
    }
    enum Kind {
        case client(Client?), discoveredClient(Client?), openURL

        var client: Client? {
            switch self {
            case .client(let client), .discoveredClient(let client): return client
            case .openURL: return nil
            }
        }
        
        var isDiscoveredClient: Bool {
            switch self {
            case .discoveredClient: return true
            case .client, .openURL: return false
            }
        }
        
        var isOpenURL: Bool {
            switch self {
            case .openURL: return true
            case .client, .discoveredClient: return false
            }
        }
    }
    
    // MARK: Views
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var hostLabel: UILabel!
    @IBOutlet private var statusImageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Content
    private func updateContent() {
        switch kind {
        case .client(let client):
            accessoryType = .none
            if let client = client {
                nameLabel.text = client.name
                hostLabel.text = [client.host, String(client.port ?? 0)].joined(separator: ":")
            } else {
                nameLabel.text = nil
                hostLabel.text = nil
            }
            
            
        case .discoveredClient(let client):
            accessoryType = .disclosureIndicator
            if let client = client {
                nameLabel.text = client.name
                hostLabel.text = client.host
            } else {
                nameLabel.text = "clients.addcustom.line1".localized
                hostLabel.text = "clients.addcustom.line2".localized
            }

            
        case .openURL:
            accessoryType = .none
            nameLabel.text = "clients.openurl.line1".localized
            hostLabel.text = "clients.openurl.line2".localized
        }
    }
    
    @objc private func updateStatus() {
        var loading = ClientStatusManager.shared.isClientLoading(kind.client)
        var status  = ClientStatusManager.shared.lastStatusForClient(kind.client)
        
        if kind.isDiscoveredClient {
            if kind.client == nil {
                loading = true
            }
            if kind.client != nil {
                status = .online
            }
        }
        
        // show loading only if previous status is unknown, else show last status
        if loading && status == .unknown {
            statusImageView.image = nil
            activityIndicator.startAnimating()
            return
        }
        
        switch status {
        case .online:
            statusImageView.image = UIImage.traffic(.green)
            activityIndicator.stopAnimating()
        case .offline:
            statusImageView.image = UIImage.traffic(.grey)
            activityIndicator.stopAnimating()
        case .unknown:
            statusImageView.image = nil
            activityIndicator.stopAnimating()
        }
        
        if #available(iOS 13.0, *), kind.isOpenURL {
            statusImageView.image = UIImage(systemName: "arrowshape.turn.up.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?.masking(with: .seeder)
            activityIndicator.stopAnimating()
        }
    }
}
