//
//  EditClientVC.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

class EditClientVC: ViewController {
    
    // MARK: Init
    init(client: Client) {
        self.client = client.copy(keepID: true)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        isCreation = Preferences.shared.clientWithIdentifier(client.id) == nil
        title = isCreation ? "client.title.new".localized : "client.title.edit".localized
        isModalInPresentation = true
        
        navigationItem.rightBarButtonItems = [
            .close(target: self, action: #selector(close)),
            .save(target: self, action: #selector(saveAndClose))
        ]
        
        tableView.registerCell(ClientFormCell.self)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Properties
    private var client: Client
    private var isCreation: Bool = false
    
    // MARK: Views
    @IBOutlet private var tableView: UITableView!

    // MARK: Actions
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func saveAndClose() {
        let errors = client.formErrors
        guard errors.isEmpty else {
            let errorsList = errors.map { $0.value.message(for: $0.key) }.joined(separator: ", ")
            UIAlertController.show(title: "error.form".localized, message: errorsList, close: "action.close".localized, in: self)
            return
        }

        Preferences.shared.addClient(client)
        dismiss(animated: true, completion: nil)
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
