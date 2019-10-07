//
//  SYClientCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class SYClientCell: UITableViewCell {
    
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
    var isDiscoveredClient: Bool = false {
        didSet {
            updateContent()
            updateStatus()
        }
    }
    var client: Client? {
        didSet {
            updateContent()
            updateStatus()
        }
    }
    
    // MARK: Views
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var hostLabel: UILabel!
    @IBOutlet private var statusImageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Content
    private func updateContent() {
        accessoryType = isDiscoveredClient ? .disclosureIndicator : .none
        if let client = client {
            nameLabel.text = client.name
            if isDiscoveredClient {
                hostLabel.text = client.host
            }
            else {
                hostLabel.text = [client.host, String(client.port ?? 0)].joined(separator: ":")
            }
        }
        else if isDiscoveredClient
        {
            nameLabel.text = "clients.addcustom.line1".localized
            hostLabel.text = "clients.addcustom.line2".localized
        }
        else
        {
            nameLabel.text = nil
            hostLabel.text = nil
        }
    }
    
    @objc private func updateStatus() {
        var loading = ClientStatusManager.shared.isClientLoading(client)
        var status  = ClientStatusManager.shared.lastStatusForClient(client)
        
        if isDiscoveredClient && client == nil {
            loading = true
        }
        if isDiscoveredClient && client != nil {
            status = .online
        }
        
        // show loading only if previous status is unknown, else show last status
        if loading && status == .unknown {
            statusImageView.image = nil
            activityIndicator.startAnimating()
            return
        }
        
        switch status {
        case .online:
            statusImageView.image = UIImage(named: "traffic_green")
            activityIndicator.stopAnimating()
        case .offline:
            statusImageView.image = UIImage(named: "traffic_grey")
            activityIndicator.stopAnimating()
        case .unknown:
            statusImageView.image = nil
            activityIndicator.stopAnimating()
        }
    }
}
