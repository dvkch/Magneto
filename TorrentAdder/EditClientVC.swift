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
        
        tableView.registerCell(ClientFormCell.self)
        
        if isCreation {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 60))
            tableView.tableFooterView = footer
            
            let addButton = AddButton()
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.addTarget(self, action: #selector(self.addButtonTap), for: .touchUpInside)
            footer.addSubview(addButton)
            
            addButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            addButton.centerXAnchor.constraint(equalTo: footer.centerXAnchor).isActive = true
            addButton.centerYAnchor.constraint(equalTo: footer.centerYAnchor).isActive = true
        }
        else {
            self.tableView.tableFooterView = UIView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isCreation {
            saveClient(force: true)
        }
    }
    
    // MARK: Properties
    var client: Client!
    private var isCreation: Bool = false
    
    // MARK: Views
    @IBOutlet private var tableView: UITableView!

    // MARK: Actions
    @objc private func addButtonTap() {
        if saveClient(force: false) {
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
