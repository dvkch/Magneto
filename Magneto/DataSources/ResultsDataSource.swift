//
//  ResultsDataSource.swift
//  Magneto
//
//  Created by syan on 24/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import UIKit

class ResultsDataSource: UITableViewDiffableDataSource<Int, IdentifiableResult> {
    
    // MARK: Init
    init(tableView: UITableView, cellDelegate: ResultCellDelegate) {
        weak var wCellDelegate = cellDelegate
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueCell(ResultCell.self, for: indexPath)
            cell.result = itemIdentifier.result
            cell.delegate = wCellDelegate
            return cell
        }
    }
    
    // MARK: Results
    private var pages: [[any SearchResult]] = []
    
    private func applyResults(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, IdentifiableResult>()
        snapshot.appendSections([0])
        snapshot.appendItems(pages.reduce([], +).map({ .init(result: $0) }), toSection: 0)
        apply(snapshot, animatingDifferences: animated)
    }
    
    func clear(animated: Bool) {
        self.pages = []
        applyResults(animated: animated)
    }
    
    func insert(_ results: [any SearchResult], animated: Bool) {
        self.pages.append(results)
        applyResults(animated: animated)
    }
    
    var pagesCount: Int {
        return pages.count
    }
    
    var lastPageCount: Int? {
        return pages.last?.count
    }
    
    func isLastItem(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row == snapshot().numberOfItems - 1
    }
    
    // MARK: Sections
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 0 else { return nil }

        guard let searchResults = pages.first else { return nil }
        return searchResults.isEmpty ? "clients.section.noresults".localized : "clients.section.results".localized
    }
}
