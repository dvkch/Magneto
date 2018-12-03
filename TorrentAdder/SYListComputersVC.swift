//
//  SYListComputersVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class SYListComputersVC: UIViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add a client"

        progressView.progressTintColor = .lightBlue
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.closeButtonTap))
        navigationItem.leftBarButtonItem = closeButton
        
        tableView.registerCell(name: SYComputerCell.className)
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hostnameResolverUpdatedNotification), name: .hostnameResolverUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .hostnameResolverUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPinging()
    }
    
    // MARK: Properties
    private var availableIPs: [String] = []
    private var pinger: SYPinger?
    // MARK: View
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: Actions
    @objc private func closeButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Notifications
    @objc private func hostnameResolverUpdatedNotification() {
        reload()
    }
    
    // MARK: Content
    private func reload() {
        tableView.reloadData()
    }
    
    private func addAvailableIP(_ ip: String?) {
        guard let ip = ip else { return }
        availableIPs.append(ip)
        availableIPs.sort { (ip1, ip2) -> Bool in
            return ip1.compare(ip2, options: .numeric) == .orderedAscending
        }
        
        if let index = availableIPs.index(of: ip) {
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            tableView.endUpdates()
        }
        else {
            tableView.reloadData()
        }
    }
    
    // MARK: Ping
    private func startPinging() {
        guard pinger == nil else { return }
        
        pinger = SYPinger(networks: SYIPv4Interface.deviceNetworks(filterLocalInterfaces: true))
        pinger?.progressBlock = { [weak self] (progress) in
            self?.progressView.setProgress(Float(progress), animated: true)
        }
        pinger?.ipFoundBlock = { [weak self] (ip) in
            self?.addAvailableIP(ip)
        }
        pinger?.finishedBlock = { [weak self] (finished) in
            self?.progressView?.setProgress(1, animated: true)
        }
        
        progressView.progress = 0
        pinger?.start()
    }
}

extension SYListComputersVC : UITableViewDataSource {
    func client(at indexPath: IndexPath) -> SYClient? {
        guard indexPath.row < availableIPs.count else { return  nil }
        let host = availableIPs[indexPath.row]
        let name = SYHostnameResolver.shared.hostnameForIP(host) ?? host
        return SYClient(host: host, name: name)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableIPs.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: SYComputerCell.self, indexPath: indexPath)
        cell.isDiscoveredClient = true
        cell.client = client(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available clients"
    }
}

extension SYListComputersVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = SYEditComputerVC()
        vc.client = client(at: indexPath) ?? SYClient(host: "", name: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}
