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
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: .SYNetworkManagerComputerStatusChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .SYNetworkManagerComputerStatusChanged, object: nil)
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
        var status = SYComputerStatus_Unknown
        if !isAvailableComputersList {
            status = SYNetworkManager.shared.status(forComputer: computer)
            let prevStatus = SYNetworkManager.shared.previousStatus(forComputer: computer)
            if status == SYComputerStatus_Waiting && prevStatus != SYComputerStatus_Unknown {
                status = prevStatus
            }
        }
        if isAvailableComputersList && computer != nil {
            status = SYComputerStatus_Opened
        }
        if isAvailableComputersList && computer == nil {
            status = SYComputerStatus_Waiting
        }
        
        switch status {
        case SYComputerStatus_Unknown:
            statusImageView.image = nil
            activityIndicator.stopAnimating()
        case SYComputerStatus_Waiting:
            statusImageView.image = nil
            activityIndicator.startAnimating()
        case SYComputerStatus_Closed:
            statusImageView.image = UIImage(named: "traffic_grey")
            activityIndicator.stopAnimating()
        case SYComputerStatus_Opened:
            statusImageView.image = UIImage(named: "traffic_green")
            activityIndicator.stopAnimating()
        // TODO: remove when using native enum
        default:
            break;
        }
    }
}
