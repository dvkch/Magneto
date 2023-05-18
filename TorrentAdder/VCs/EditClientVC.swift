//
//  EditClientVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

class EditClientVC: ViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        isCreation = Preferences.shared.clientWithIdentifier(client.id) == nil
        title = isCreation ? "client.title.new".localized : "client.title.edit".localized
        isModalInPresentation = true
        
        if isCreation {
            navigationItem.rightBarButtonItem = .save(target: self, action: #selector(close))
        }
        else {
            navigationItem.rightBarButtonItem = .close(target: self, action: #selector(close))
        }
        
        tableView.registerCell(ClientFormCell.self)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Properties
    var client: Client!
    private var isCreation: Bool = false
    
    // MARK: Views
    @IBOutlet private var tableView: UITableView!

    // MARK: Actions
    @objc private func close() {
        if saveClient(force: !isCreation) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Content
    @discardableResult
    private func saveClient(force: Bool) -> Bool {
        if client == nil { return true }
        if client.port == nil || client.port == 0 {
            client.port = client.software.defaultPort
        }
        
        if !client.isValid && !force {
            return false
        }
        
        Preferences.shared.addClient(client)
        return true
    }
}

extension EditClientVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Client.FormField.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ClientFormCell.self, for: indexPath)
        cell.client = client
        cell.formField = Client.FormField.allCases[indexPath.row]
        return cell
    }
}
