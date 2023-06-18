//
//  ClientsDataSource.swift
//  Magneto
//
//  Created by syan on 18/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

class ClientsDataSources: UITableViewDiffableDataSource<Int, ClientCell.Kind> {
    
    // MARK: Init
    init(tableView: UITableView, sectionTitle: String?, showAdd: Bool, showMagnet: Bool) {
        self.sectionTitle = sectionTitle
        self.showAdd = showAdd
        self.showMagnet = showMagnet

        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueCell(ClientCell.self, for: indexPath)
            cell.kind = itemIdentifier
            return cell
        }

        NotificationCenter.default.addObserver(self, selector: #selector(clientsChanged), name: .clientsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clientsChanged), name: .clientStatusChanged, object: nil)
        refreshClients(animated: false)
    }
    
    // MARK: Properties
    let sectionTitle: String?
    let showAdd: Bool
    let showMagnet: Bool
    
    // MARK: Auto refresh
    @objc private func clientsChanged() {
        refreshClients(animated: true) // check if view is visible ?
    }

    // MARK: Content
    private func refreshClients(animated: Bool) {
        let sortedClients = Preferences.shared.clients.sortedByAvailability

        var snapshot = NSDiffableDataSourceSnapshot<Int, ClientCell.Kind>()

        snapshot.appendSections([0])

        if showMagnet {
            snapshot.appendItems([.openURL])
        }

        snapshot.appendItems(sortedClients.map { .client($0) })

        if showAdd {
            snapshot.appendItems([.newClient])
        }

        apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle
    }
}
