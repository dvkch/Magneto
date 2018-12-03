//
//  SYEditComputerVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

class SYEditComputerVC: UIViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        isCreation = SYPreferences.shared.computerWithIdentifier(computer.id) == nil
        title = isCreation ? "New computer" : "Edit computer"
        
        tableView.registerCell(name: SYComputerFormCell.className)
        
        if isCreation {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 60))
            tableView.tableFooterView = footer
            
            let addButton = SYButton()
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.tintColor = .white
            addButton.backColor = .lightBlue
            addButton.text = "+"
            addButton.textOffset = .init(width: 0, height: -2)
            addButton.fontSize = 30
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isCreation {
            saveComputer(force: true)
        }
    }
    
    // MARK: Properties
    var computer: SYClient!
    private var isCreation: Bool = false
    
    // MARK: Views
    @IBOutlet private var tableView: UITableView!

    // MARK: Actions
    @objc private func addButtonTap() {
        if saveComputer(force: false) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Content
    @discardableResult
    private func saveComputer(force: Bool) -> Bool {
        if computer == nil { return true }
        if computer.port == nil || computer.port == 0 {
            computer.port = computer.software.defaultPort
        }
        
        if !computer.isValid && !force {
            return false
        }
        
        SYPreferences.shared.addComputer(computer)
        return true
    }
}

extension SYEditComputerVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SYClient.FormField.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: SYComputerFormCell.self, indexPath: indexPath)
        cell.computer = computer
        cell.formField = SYClient.FormField.allCases[indexPath.row]
        return cell
    }
}

extension SYEditComputerVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
