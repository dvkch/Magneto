//
//  SYComputerCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class SYComputerCell: UITableViewCell {
    
    // MARK: Init
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: .clientStatusChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .clientStatusChanged, object: nil)
    }
    
    // MARK: Properties
    var isAvailableComputersList: Bool = false {
        didSet {
            updateContent()
            updateStatus()
        }
    }
    var computer: SYComputerModel? {
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
        accessoryType = isAvailableComputersList ? .disclosureIndicator : .none
        if let computer = computer {
            nameLabel.text = computer.name
            if isAvailableComputersList {
                hostLabel.text = computer.host
            }
            else {
                hostLabel.text = [computer.host ?? "", String(computer.port)].joined(separator: ":")
            }
        }
        else if isAvailableComputersList
        {
            nameLabel.text = "Add a custom computer"
            hostLabel.text = "in case yours wasn't detected"
        }
        else
        {
            nameLabel.text = nil
            hostLabel.text = nil
        }
    }
    
    @objc private func updateStatus() {
        let loading = (isAvailableComputersList && computer == nil) ? true    : SYClientStatusManager.shared.isComputerLoading(computer)
        let status  = (isAvailableComputersList && computer != nil) ? .online : SYClientStatusManager.shared.lastStatusForComputer(computer)
        
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
