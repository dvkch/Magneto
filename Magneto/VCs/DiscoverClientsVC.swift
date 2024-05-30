//
//  DiscoverClientsVC.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Disco
import Network

class DiscoverClientsVC: ViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Discovery.title
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
        
        finder = HostsFinder(interfaces: IPv4Interface.availableInterfaces().filter { $0.isLocal })
        finder.delegate = self
        finder.start()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .hostnameResolverUpdated, object: nil)
    }
    
    // MARK: Properties
    private var availableIPs: [IPv4Address] = []
    private var finder = HostsFinder(interfaces: [])

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
    private func addAvailableIP(_ ip: IPv4Address) {
        availableIPs.append(ip)
        availableIPs.sort(by: { $0.decimalRepresentation < $1.decimalRepresentation })
        
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

extension DiscoverClientsVC : HostsFinderDelegate {
    func hostsFinder(_ hostsFinder: HostsFinder, progressUpdated progress: Float) {
        progressView.setProgress(Float(progress), animated: true)
    }
    
    func hostsFinder(_ hostsFinder: HostsFinder, stopped completed: Bool) {
        progressView.setProgress(1, animated: true)
    }

    func hostsFinder(_ hostsFinder: HostsFinder, found ip: IPv4Address) {
        addAvailableIP(ip)
    }
}

extension DiscoverClientsVC : UITableViewDataSource {
    func client(at indexPath: IndexPath) -> Client? {
        guard indexPath.row < availableIPs.count else { return  nil }
        let host = availableIPs[indexPath.row]
        let name = HostnameResolver.shared.hostname(for: host.stringRepresentation) ?? host.stringRepresentation
        return Client(host: host.stringRepresentation, name: name)
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
        return L10n.Discovery.Section.found
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
