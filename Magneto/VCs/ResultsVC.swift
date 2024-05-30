//
//  ResultsVC.swift
//  Magneto
//
//  Created by syan on 18/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit
import SYKit

protocol ResultsVCDelegate: NSObjectProtocol {
    func resultsVC(_ resultsVC: ResultsVC, isLoading: Bool)
}

class ResultsVC: ViewController {
    
    // MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        tableView.separatorStyle = .singleLine // force their appearance on catalyst
        tableView.registerCell(ResultCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        tableView.dataSource = dataSource
        tableView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(searchAPIChanged), name: .searchAPIChanged, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Properties
    var searchController: UISearchController!
    weak var delegate: ResultsVCDelegate?
    private var searchQuery: String = "" {
        didSet {
            guard searchQuery != oldValue else { return }
            loadNextPage(clear: true, animated: false)
        }
    }
    private lazy var dataSource = ResultsDataSource(tableView: tableView, cellDelegate: self)
    private var isLoadingResults: Bool = false {
        didSet {
            delegate?.resultsVC(self, isLoading: isLoadingResults)
        }
    }

    // MARK: Views
    @IBOutlet private var tableView: UITableView!

    #if !targetEnvironment(macCatalyst)
    private weak var suggestionsVC: SuggestionsVC?
    #endif

    // MARK: Actions
    @objc private func searchAPIChanged() {
        loadNextPage(clear: true, animated: false)
    }

    fileprivate func loadNextPage(clear: Bool, animated: Bool) {
        if clear {
            dataSource.clear(animated: false)
        }

        guard searchQuery.isNotEmpty, dataSource.lastPageCount != 0 else {
            isLoadingResults = false
            return
        }
        
        let query = self.searchQuery
        isLoadingResults = true

        let closure = { [weak self] (result: Result<[any SearchResult], AppError>) in
            guard let self = self else { return }
            guard self.searchQuery == query else { return }
            
            self.isLoadingResults = false

            switch result {
            case .success(let items):
                self.dataSource.insert(items, animated: animated)
                Preferences.shared.addHistory(query)
                
            case .failure(let error):
                UIAlertController.show(
                    for: error, title: L10n.Error.Title.cannotLoadResults,
                    close: L10n.Action.close, in: self
                )
            }
        }
        
        let page = dataSource.pagesCount
        switch Preferences.shared.searchAPI {
        case .tpb:
            SearchAPITpb.shared.getResults(query: query, page: page).onComplete {
                closure($0.map { $0 as [any SearchResult] })
            }
        case .leetx:
            SearchAPILeetx.shared.getResults(query: query, page: page).onComplete {
                closure($0.map { $0 as [any SearchResult] })
            }
        case .t9:
            SearchAPIT9.shared.getResults(query: query, page: page).onComplete {
                closure($0.map { $0 as [any SearchResult] })
            }
        case .yts:
            SearchAPIYts.shared.getResults(query: query, page: page).onComplete {
                closure($0.map { $0 as [any SearchResult] })
            }
        }
    }
    
    fileprivate func shareResult(_ result: any SearchResult, from sender: UIView) {
        let hud = HUDAlertController.show(in: self)
        result.pageURL()
            .andThen { _ in HUDAlertController.dismiss(hud, animated: false) }
            .onFailure { (error) in
                UIAlertController.show(for: error, close: L10n.Action.close, in: self)
            }
            .onSuccess { (pageURL) in
                let vc = UIActivityViewController(activityItems: [pageURL], applicationActivities: nil)
                vc.popoverPresentationController?.sourceRect = sender.frame
                vc.popoverPresentationController?.sourceView = sender
                
                self.present(vc, animated: true, completion: nil)
                self.tableView.setEditing(false, animated: true)
        }
    }
    
    fileprivate func openResultInSafari(_ result: any SearchResult) {
        let hud: HUDAlertController?
        if result.pageURLAvailable {
            hud = nil
        }
        else {
            hud = HUDAlertController.show(in: self)
        }

        result.pageURL()
            .andThen { _ in HUDAlertController.dismiss(hud, animated: false) }
            .onFailure { (error) in
                UIAlertController.show(for: error, close: L10n.Action.close, in: self)
            }
            .onSuccess { (pageURL) in
                DispatchQueue.main.async {
                    self.openSafariURL(pageURL)
                }
                self.tableView.setEditing(false, animated: true)
        }
    }
}

extension ResultsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateSuggestions(searchBar: searchController.searchBar)
    }

    @available(iOS 16.0, *)
    func updateSearchResults(for searchController: UISearchController, selecting searchSuggestion: UISearchSuggestion) {
        searchController.searchBar.text = searchSuggestion.localizedSuggestion
        updateSuggestions(searchBar: searchController.searchBar)
    }
}

extension ResultsVC : UISearchBarDelegate {
    private func updateSuggestions(searchBar: UISearchBar) {
        let input = searchBar.text
        
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 16.0, *) {
            searchController.searchSuggestions = Preferences.shared.prevSearches(matching: input)
                .map { UISearchSuggestionItem(localizedSuggestion: $0) }
        }
        #else
        if suggestionsVC == nil && SuggestionsVC.shouldPresentPopover(for: input) {
            suggestionsVC = SuggestionsVC.present(under: searchBar, in: self)
            suggestionsVC?.selectedSuggestionBlock = { [weak self] (suggestion) in
                searchBar.text = suggestion
                self?.suggestionsVC?.input = suggestion
            }
        }

        if suggestionsVC != nil && !SuggestionsVC.shouldPresentPopover(for: input) {
            suggestionsVC?.dismiss(animated: false, completion: nil)
            suggestionsVC = nil
        }

        suggestionsVC?.input = input ?? ""
        #endif
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // when tapping the clear button we need to make sure the search results are also reset
        if searchText.isEmpty {
            searchQuery = ""
        }
        updateSuggestions(searchBar: searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        updateSuggestions(searchBar: searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if #available(iOS 16.0, *), let selectedSuggestion = searchController.selectedSuggestion {
            // search bar button was "clicked" by pressing Enter on a selected suggestion
            // we do this manually because on Catalyst pressing Enter on a suggestion triggers
            // searchBarSearchButtonClicked, but never tells that the suggestion is highlighted...
            // we also can only run this method from here or it the list of suggestions will have been cleared out...
            if selectedSuggestion.localizedSuggestion != searchBar.text {
                DispatchQueue.main.async {
                    self.updateSearchResults(for: self.searchController, selecting: selectedSuggestion)
                }
                return false
            }
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        #if !targetEnvironment(macCatalyst)
        suggestionsVC?.dismiss(animated: false, completion: nil)
        #endif
        
        searchQuery = searchBar.text ?? ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        #if !targetEnvironment(macCatalyst)
        suggestionsVC?.dismiss(animated: false, completion: nil)
        #endif
    }
}

extension ResultsVC: ResultCellDelegate {
    func resultCell(_ resultCell: ResultCell, requiresReloadFor result: any SearchResult) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func resultCell(_ resultCell: ResultCell, tapped variant: SearchResultVariant, sender: UIView) {
        openTorrentPopup(with: .result(resultCell.result!, variant), sender: sender)
    }
    
    func resultCell(_ resultCell: ResultCell, encounteredError error: AppError) {
        UIAlertController.show(for: error, close: L10n.Action.close, in: self)
    }
}

extension ResultsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard dataSource.isLastItem(indexPath) else { return }
        loadNextPage(clear: false, animated: true)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath)
        (cell as? ResultCell)?.runMainAction()
    }
    
    private func actionsForRow(at indexPath: IndexPath) -> [Action] {
        guard let result = dataSource.itemIdentifier(for: indexPath)?.result else { return [] }
        let shareAction = Action(title: L10n.Action.sharelink, icon: .share, color: .cellBackgroundAlt) { [weak self] in
            guard let cell = self?.tableView.cellForRow(at: indexPath) else { return }
            self?.shareResult(result, from: cell)
        }
        let openAction = Action(title: L10n.Action.open, icon: .openWeb, color: .tint) { [weak self] in
            self?.openResultInSafari(result)
        }
        return [openAction, shareAction]
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            return UIMenu(title: "", children: self.actionsForRow(at: indexPath).map(\.uiAction))
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = actionsForRow(at: indexPath).reversed().map(\.uiContextualAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
}
