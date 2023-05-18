//
//  ResultsVC.swift
//  TorrentAdder
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

        tableView.registerCell(ResultCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Properties
    weak var delegate: ResultsVCDelegate?
    private var searchQuery: String = "" {
        didSet {
            guard searchQuery != oldValue else { return }
            refreshResults()
        }
    }
    private var searchResults: [SearchResult]? {
        didSet {
            tableView.reloadData()
            tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        }
    }
    private var isLoadingResults: Bool = false {
        didSet {
            delegate?.resultsVC(self, isLoading: isLoadingResults)
        }
    }

    // MARK: Views
    @IBOutlet private var tableView: UITableView!
    private weak var suggestionsVC: SuggestionsVC?

    // MARK: Actions
    fileprivate func refreshResults() {
        guard searchQuery.isNotEmpty else {
            searchResults = nil
            tableView.reloadData()
            isLoadingResults = false
            return
        }
        
        let query = self.searchQuery
        isLoadingResults = true

        WebAPI.shared.getResults(query: query).onComplete { [weak self] result in
            guard let self = self else { return }
            guard self.searchQuery == query else { return }
            
            self.isLoadingResults = false

            switch result {
            case .success(let items):
                self.searchResults = items
                Preferences.shared.addPrevSearch(query)
                
            case .failure(let error):
                UIAlertController.show(
                    for: error, title: "error.title.cannotLoadResults".localized,
                    close: "action.close".localized, in: self
                )
            }
        }
    }
    
    func openTorrentPopup(with magnetURL: URL?, or result: SearchResult?) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) {
                self.openTorrentPopup(with: magnetURL, or: result)
            }
            return
        }
        
        MagnetPopupVC.show(in: self, magnet: magnetURL, result: result)
    }

    fileprivate func shareResult(_ result: SearchResult, from sender: UIView) {
        let hud = HUDAlertController.show(in: self)
        WebAPI.shared.getResultPageURL(result)
            .andThen { _ in HUDAlertController.dismiss(hud, animated: false) }
            .onFailure { (error) in
                UIAlertController.show(for: error, close: "action.close".localized, in: self)
            }
            .onSuccess { (fullURL) in
                
                let vc = UIActivityViewController(activityItems: [fullURL], applicationActivities: nil)
                vc.popoverPresentationController?.sourceRect = sender.frame
                vc.popoverPresentationController?.sourceView = sender
                
                self.present(vc, animated: true, completion: nil)
                self.tableView.setEditing(false, animated: true)
        }
    }
    
    fileprivate func openResultInSafari(_ result: SearchResult) {
        let hud = HUDAlertController.show(in: self)
        WebAPI.shared.getResultPageURL(result)
            .andThen { _ in HUDAlertController.dismiss(hud, animated: false) }
            .onFailure { (error) in
                UIAlertController.show(for: error, close: "action.close".localized, in: self)
            }
            .onSuccess { (fullURL) in
                self.openSafariURL(fullURL)
                self.tableView.setEditing(false, animated: true)
        }
    }
}

extension ResultsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateSuggestionsVC(searchBar: searchController.searchBar)
    }
}

extension ResultsVC : UISearchBarDelegate {
    private func updateSuggestionsVC(searchBar: UISearchBar) {
        // TODO: try again on catalyst ?
        #if !targetEnvironment(macCatalyst) && os(iOS)
        let input = searchBar.text

        if suggestionsVC == nil && SuggestionsVC.shouldPresentPopover(for: input) {
            suggestionsVC = SuggestionsVC.present(under: searchBar.searchTextField, in: self)
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
        updateSuggestionsVC(searchBar: searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        updateSuggestionsVC(searchBar: searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        suggestionsVC?.dismiss(animated: true, completion: nil)
        searchQuery = searchBar.text ?? ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        suggestionsVC?.dismiss(animated: true, completion: nil)
        searchBar.resignFirstResponder()
    }
}

extension ResultsVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let searchResults else { return nil }
        return searchResults.isEmpty ? "clients.section.noresults".localized : "clients.section.results".localized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ResultCell.self, for: indexPath)
        cell.result = searchResults?[indexPath.row]
        return cell
    }
}

extension ResultsVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openTorrentPopup(with: nil, or: searchResults?[indexPath.row])
    }
    
    private func actionsForRow(at indexPath: IndexPath) -> [Action] {
        guard let result = searchResults?[indexPath.row] else { return [] }
        let shareAction = Action(title: "action.sharelink".localized, icon: .share, color: .cellBackgroundAlt) { [weak self] in
            guard let cell = self?.tableView.cellForRow(at: indexPath) else { return }
            self?.shareResult(result, from: cell)
        }
        let openAction = Action(title: "action.open".localized, icon: .openWeb, color: .tint) { [weak self] in
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
