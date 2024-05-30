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
        weak var wSelf: ResultsDataSource? = nil

        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueCell(ResultCell.self, for: indexPath)
            cell.setResult(itemIdentifier.result, query: wSelf?.query)
            cell.delegate = wCellDelegate
            return cell
        }
        wSelf = self
    }
    
    // MARK: Results
    private var query: String? = nil
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
    
    func insert(_ results: [any SearchResult], for query: String, animated: Bool) {
        self.query = query
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
        return searchResults.isEmpty ? L10n.Clients.Section.noresults : L10n.Clients.Section.results
    }
}
