//
//  SYListComputersVCSwift.swift
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
        title = "Add a computer"

        progressView.progressTintColor = .lightBlue()
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.closeButtonTap))
        navigationItem.leftBarButtonItem = closeButton
        
        tableView.registerCell(name: SYComputerCell.className)
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.bonjourClientUpdatedNotification), name: .SYBonjourClientUpdatedData, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .SYBonjourClientUpdatedData, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPinging()
    }
    
    // MARK: Properties
    private var computers: [SYComputerModel] = []
    private var pinger: SYPinger?
    // MARK: View
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: Actions
    @objc private func closeButtonTap() {
        dismiss(animated: true, completion: nil)
        // TODO: ?? [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    // MARK: Notifications
    @objc private func bonjourClientUpdatedNotification() {
        reload()
    }
    
    // MARK: Content
    private func reload() {
        tableView.reloadData()
    }
    
    private func addComputer(with ip: String?) {
        guard let ip = ip else { return }
        let computer = SYComputerModel(name: nil, andHost: ip)!
        computers.append(computer)
        computers.sort { (c1, c2) -> Bool in
            return c1.host.compare(c2.host, options: .numeric) == .orderedAscending
        }
        
        let index = computers.index(of: computer)!
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    // MARK: Ping
    private func startPinging() {
        guard pinger == nil else { return }
        
        progressView.progress = 0
        pinger = SYPinger(networks: SYNetworkManager.myNetworks(true) ?? [])
        pinger?.pingNetwork(progressBlock: { [weak self] (progress) in
            self?.progressView.setProgress(Float(progress), animated: true)
            return
        }, validIpFound: { [weak self] (ip) in
            self?.addComputer(with: ip)
            return
        }, finishedBlock: { [weak self] (finished) in
            self?.progressView?.setProgress(1, animated: true)
            return
        })
    }
}

extension SYListComputersVC : UITableViewDataSource {
    func computer(at indexPath: IndexPath) -> SYComputerModel? {
        return indexPath.row >= computers.count ? nil : computers[indexPath.row]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return computers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SYComputerCell.className, for: indexPath) as! SYComputerCell
        cell.computer = computer(at: indexPath)
        cell.isAvailableComputersList = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available computers"
    }
}

extension SYListComputersVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = SYEditComputerVC()
        vc.computer = computer(at: indexPath) ?? SYComputerModel(name: nil, andHost: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}
