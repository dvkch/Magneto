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
        activityIndicator.color = .normalText
        nameLabel.textColor = .normalText
        hostLabel.textColor = .altText
        backgroundColor = .cellBackground
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
        case client(Client?), discoveredClient(Client?), newClient, openURL

        var client: Client? {
            switch self {
            case .client(let client), .discoveredClient(let client): return client
            case .newClient, .openURL: return nil
            }
        }
        
        var isDiscoveredClient: Bool {
            switch self {
            case .discoveredClient: return true
            case .client, .newClient, .openURL: return false
            }
        }
        
        var isOpenURL: Bool {
            switch self {
            case .openURL: return true
            case .client, .discoveredClient, .newClient: return false
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
            if let client = client {
                nameLabel.text = client.name
                hostLabel.text = [client.host, String(client.port ?? 0)].joined(separator: ":")
            } else {
                nameLabel.text = nil
                hostLabel.text = nil
            }
            accessoryType = .none
            accessoryView = nil
            
        case .discoveredClient(let client):
            if let client = client {
                nameLabel.text = client.name
                hostLabel.text = client.host
            } else {
                nameLabel.text = "clients.addcustom.line1".localized
                hostLabel.text = "clients.addcustom.line2".localized
            }
            accessoryType = .disclosureIndicator
            accessoryView = nil
            
        case .newClient:
            nameLabel.text = "clients.count.add".localized
            hostLabel.text = nil

            let imageView = UIImageView(image: UIImage(named: "button_add"))
            imageView.tintColor = nameLabel.textColor
            imageView.contentMode = .scaleAspectFit
            let size = UIFontMetrics.default.scaledValue(for: 20)
            imageView.frame.size = .init(width: size, height: size)
            accessoryView = imageView
            accessoryType = .none

        case .openURL:
            nameLabel.text = "clients.openurl.line1".localized
            hostLabel.text = "clients.openurl.line2".localized
            accessoryView = nil
            accessoryType = .none
        }
    }
    
    @objc private func updateStatus() {
        var status: ClientStatusManager.ClientStatus? = nil
        if let client = kind.client {
            status = ClientStatusManager.shared.statusForClient(client)
        }
        if kind.isDiscoveredClient {
            status = kind.client != nil ? .online : .unknown
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
            activityIndicator.startAnimating()
        case .none:
            statusImageView.image = nil
            activityIndicator.stopAnimating()
        }
        
        if kind.isOpenURL {
            statusImageView.image = UIImage(systemName: "arrowshape.turn.up.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?.masking(with: .seeder)
            activityIndicator.stopAnimating()
        }
    }
}
