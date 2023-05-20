//
//  DiscoverClientsVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class DiscoverClientsVC: ViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "discovery.title".localized
        navigationItem.leftBarButtonItem = .close(target: self, action: #selector(closeButtonTap))
        
        progressView.progress = 0
        progressView.trackTintColor = .background
        progressView.progressTintColor = .tint
        
        tableView.registerCell(ClientCell.self)
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.hostnameResolverUpdatedNotification),
            name: .hostnameResolverUpdated, object: nil
        )
        
        pinger.delegate = self
        pinger.start()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .hostnameResolverUpdated, object: nil)
    }
    
    // MARK: Properties
    private var availableIPs: [String] = []
    private let pinger: Pinger = Pinger(networks: IPv4Interface.deviceNetworks(filterLocalInterfaces: true))

    // MARK: View
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: Actions
    @objc private func closeButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Notifications
    @objc private func hostnameResolverUpdatedNotification() {
        tableView.reloadData()
    }
    
    // MARK: Content
    private func addAvailableIP(_ ip: String?) {
        guard let ip = ip else { return }
        availableIPs.append(ip)
        availableIPs.sort { (ip1, ip2) -> Bool in
            return ip1.compare(ip2, options: .numeric) == .orderedAscending
        }
        
        if let index = availableIPs.firstIndex(of: ip) {
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            tableView.endUpdates()
        }
        else {
            tableView.reloadData()
        }
    }
}

extension DiscoverClientsVC : PingerDelegate {
    func pinger(_ pinger: Pinger, progressUpdated progress: Float) {
        progressView.setProgress(Float(progress), animated: true)
    }
    
    func pinger(_ pinger: Pinger, stopped completed: Bool) {
        progressView.setProgress(1, animated: true)
    }

    func pinger(_ pinger: Pinger, found ip: String) {
        addAvailableIP(ip)
    }
}

extension DiscoverClientsVC : UITableViewDataSource {
    func client(at indexPath: IndexPath) -> Client? {
        guard indexPath.row < availableIPs.count else { return  nil }
        let host = availableIPs[indexPath.row]
        let name = HostnameResolver.shared.hostname(for: host) ?? host
        return Client(host: host, name: name)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableIPs.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ClientCell.self, for: indexPath)
        cell.kind = .discoveredClient(client(at: indexPath), index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "discovery.section.found".localized
    }
}

extension DiscoverClientsVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let client = client(at: indexPath) ?? Client(host: "", name: "")
        let vc = EditClientVC(client: client)
        navigationController?.pushViewController(vc, animated: true)
    }
}
