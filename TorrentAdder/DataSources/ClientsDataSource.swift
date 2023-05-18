//
//  ClientsDataSource.swift
//  TorrentAdder
//
//  Created by syan on 18/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

class ClientsDataSources: UITableViewDiffableDataSource<Int, ClientCell.Kind> {
    
    // MARK: Init
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueCell(ClientCell.self, for: indexPath)
            cell.kind = itemIdentifier
            return cell
        }
    }
    
    // MARK: Convenience
    func update(with clients: [Client], showAdd: Bool, animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ClientCell.Kind>()

        snapshot.appendSections([0])

        snapshot.appendItems(clients.map { .client($0) })
        if showAdd {
            snapshot.appendItems([.newClient])
        }

        apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "clients.section.clients".localized
    }
}
