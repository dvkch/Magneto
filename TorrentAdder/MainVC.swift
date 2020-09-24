//
//  MainVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit
import SafariServices
import SVProgressHUD

class MainVC: ViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.mirrorsChanged), name: .mirrorsChanged, object: nil)

        timerRefreshClientsStatus = Timer(timeInterval: 5, target: self, selector: #selector(self.timerRefreshClientsStatusTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timerRefreshClientsStatus!, forMode: .common)

        titleLabel.addGlow(color: .lightGray, size: 4)
        
        spinner.strokeColor = .textOverAccent
        spinner.radius = 13
        spinner.strokeThickness = 3
        spinner.isHidden = true
        
        mirrorLabelContainer.layer.cornerRadius = 3
        mirrorLabelContainer.layer.masksToBounds = true
        mirrorsChanged()

        searchField.textField?.backgroundColor = .fieldBackground
        searchField.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchField.keyboardType = .default
        searchField.placeholder = "placeholder.search".localized
        
        tableView.registerCell(AddClientCell.self)
        tableView.registerCell(ClientCell.self)
        tableView.registerCell(ResultCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        
        constraintHeaderHeightOriginalValue = constraintHeaderHeight.constant
        
        // make sure the list has an initial value at init time, in case the app is opened from a magnet
        clients = Preferences.shared.clients
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        clients = Preferences.shared.clients
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerRefreshClientsStatusTick()
    }
    
    deinit {
        timerRefreshClientsStatus?.invalidate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Properties
    private var timerRefreshClientsStatus: Timer?
    private var clients: [Client] = []
    private var searchResults: [SearchResult] = []
    private var searchQuery: String = ""
    private var constraintHeaderHeightOriginalValue: CGFloat = 0
    private var isVisible: Bool = false
    private var showingSearch: Bool { return !searchQuery.isEmpty }
    private weak var suggestionsVC: SuggestionsVC?
    
    // MARK: Views
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var constraintHeaderHeight: NSLayoutConstraint!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var spinner: SVIndefiniteAnimatedView!
    @IBOutlet private var mirrorLabelContainer: UIView!
    @IBOutlet private var mirrorLabel: UILabel!
    @IBOutlet private var searchField: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var helpButton: HelpButton!
    
    // MARK: Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        helpButton.layer.cornerRadius = helpButton.bounds.height / 2
    }
}

// MARK: Notifications
extension MainVC {
    @objc private func mirrorsChanged() {
        if let host = WebAPI.shared.availableMirrorURLs.first?.host {
            mirrorLabel.text = String(format: "mirror.current %@".localized, host)
        } else {
            mirrorLabel.text = "mirror.none".localized
        }
    }
}

// MARK: Timer
extension MainVC {
    
    @objc private func timerRefreshClientsStatusTick() {
        if view.window == nil { return }
        clients.forEach {
            ClientStatusManager.shared.startStatusUpdateIfNeeded(for: $0)
        }
    }
}

// MARK: Actions
extension MainVC {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            WebAPI.shared.clearMirrors()
            return
        }
        super.motionEnded(motion, with: event)
    }
    
    @IBAction private func helpButtonTap() {
        let alert = UIAlertController(
            title: "alert.help.title".localized,
            message: "alert.help.message".localized,
            preferredStyle: .alert
        )
        alert.addAction(title: "action.close".localized, style: .cancel, handler: nil)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func updateSearch(_ text: String) {
        searchQuery = text
        
        guard !searchQuery.isEmpty else {
            searchResults = []
            tableView.reloadData()
            spinner.isHidden = true
            return
        }
        
        spinner.isHidden = false
        
        _ = WebAPI.shared.getResults(query: text)
            .andThen { [weak self] result in
                
                guard let self = self else { return }
                guard self.searchQuery == text else { return }
                
                self.spinner.isHidden = true

                switch result {
                case .success(let items):
                    self.searchResults = items
                    self.tableView.reloadData()
                    self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
                    Preferences.shared.addPrevSearch(text)
                    
                case .failure(let error):
                    self.showError(error, title: "error.title.cannotLoadResults".localized)
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
        
        #if !targetEnvironment(macCatalyst) && os(iOS)
        guard !clients.isEmpty else {
            showError(AppError.noClientsSaved, title: "error.title.cannotAddTorrent".localized)
            return
        }
        #endif

        MagnetPopupVC.show(in: self, magnet: magnetURL, result: result)
    }
    
    fileprivate func openSafariURL(_ url: URL) {
        #if targetEnvironment(macCatalyst)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        #elseif os(iOS)
        let vc = SFSafariViewController(url: url)
        if #available(iOS 13.0, *) {
            vc.preferredBarTintColor = UIColor.accent.resolvedColor(with: traitCollection)
            vc.preferredControlTintColor = UIColor.text.resolvedColor(with: traitCollection)
        } else {
            vc.preferredBarTintColor = UIColor.accent
            vc.preferredControlTintColor = UIColor.text
        }
        present(vc, animated: true, completion: nil)
        #endif
    }
    
    fileprivate func removeFinished(in client: Client) {
        SVProgressHUD.show()
        ClientAPI.shared.removeCompletedTorrents(in: client)
            .andThen { _ in SVProgressHUD.dismiss() }
            .onSuccess { (count) in
                if count > 0 {
                    SVProgressHUD.showSuccess(withStatus: String(format: "torrent.removed.%d".localized, count))
                } else {
                    SVProgressHUD.showSuccess(withStatus: nil)
                }
            }
            .onFailure { error in self.showError(error) }
    }
    
    fileprivate func removeClient(_ client: Client, at indexPath: IndexPath) {
        Preferences.shared.removeClient(client)
        clients = Preferences.shared.clients
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
        tableView.endUpdates()
    }
    
    fileprivate func shareResult(_ result: SearchResult, from cell: UITableViewCell) {
        SVProgressHUD.show()
        WebAPI.shared.getResultPageURL(result)
            .andThen { _ in SVProgressHUD.dismiss() }
            .onFailure { (error) in self.showError(error) }
            .onSuccess { (fullURL) in
                
                let vc = UIActivityViewController(activityItems: [fullURL], applicationActivities: nil)
                vc.popoverPresentationController?.sourceRect = cell.frame
                vc.popoverPresentationController?.sourceView = cell
                
                self.present(vc, animated: true, completion: nil)
                self.tableView.setEditing(false, animated: true)
        }
    }
    
    fileprivate func openResultInSafari(_ result: SearchResult) {
        SVProgressHUD.show()
        WebAPI.shared.getResultPageURL(result)
            .andThen { _ in SVProgressHUD.dismiss() }
            .onFailure { (error) in self.showError(error) }
            .onSuccess { (fullURL) in
                self.openSafariURL(fullURL)
                self.tableView.setEditing(false, animated: true)
        }
    }
}

extension MainVC : UISearchBarDelegate {
    private func updateSuggestionsVC(searchBar: UISearchBar) {
        #if !targetEnvironment(macCatalyst) && os(iOS)
        let input = searchBar.text

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
            updateSearch("")
        }
        updateSuggestionsVC(searchBar: searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        updateSuggestionsVC(searchBar: searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        suggestionsVC?.dismiss(animated: true, completion: nil)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        suggestionsVC?.dismiss(animated: true, completion: nil)
        updateSearch(searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
}

extension MainVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        constraintHeaderHeight.constant = constraintHeaderHeightOriginalValue - min(0, scrollView.contentOffset.y)
    }
}

extension MainVC : UITableViewDataSource {
    enum TableSection : Int, CaseIterable {
        case buttons, clients, results
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = TableSection(rawValue: section) else { return 0 }
        switch tableSection {
        case .buttons: return showingSearch ? 0 : 1
        case .clients: return showingSearch ? 0 : clients.count
        case .results: return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tableSection = TableSection(rawValue: section) else { return nil }
        switch tableSection {
        case .buttons: return showingSearch ? nil : "clients.section.clients".localized
        case .clients: return nil
        case .results:
            if !showingSearch { return nil }
            return searchResults.isEmpty ? "clients.section.noresults".localized : "clients.section.results".localized
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch tableSection {
        case .buttons:
            let cell = tableView.dequeueCell(AddClientCell.self, for: indexPath)
            cell.clientsCount = clients.count
            cell.addButtonTapBlock = { [weak self] in
                let vc = DiscoverClientsVC()
                let nc = NavigationController(rootViewController: vc)
                self?.present(nc, animated: true, completion: nil)
            }
            return cell
        case .clients:
            let cell = tableView.dequeueCell(ClientCell.self, for: indexPath)
            cell.kind = .client(clients[indexPath.row])
            return cell
        case .results:
            let cell = tableView.dequeueCell(ResultCell.self, for: indexPath)
            cell.result = searchResults[indexPath.row]
            return cell
        }
    }
}

extension MainVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.tableView(tableView, titleForHeaderInSection: section) != nil else { return 0 }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return }
        switch tableSection {
        case .buttons:
            let vc = DiscoverClientsVC()
            let nc = NavigationController(rootViewController: vc)
            present(nc, animated: true, completion: nil)

        case .clients:
            let client = clients[indexPath.row]
            var url = client.webURL
            if let username = client.username?.nilIfEmpty, let password = client.password?.nilIfEmpty, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                components.user = username
                components.password = password
                url = components.url ?? url
            }
            self.openSafariURL(url)

        case .results:
            self.openTorrentPopup(with: nil, or: searchResults[indexPath.row])
        }
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return nil }
        switch tableSection {
        case .buttons:
            return nil
            
        case .clients:
            let client = clients[indexPath.row]
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
                let removeFinishedAction = UIAction(title: "action.removefinished".localized, image: UIImage(systemName: "tray")) { [weak self] (_) in
                    self?.removeFinished(in: client)
                }
                let editAction = UIAction(title: "action.edit".localized, image: UIImage(systemName: "square.and.pencil")) { [weak self] (_) in
                    let vc = EditClientVC()
                    vc.client = client
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                let deleteAction = UIAction(title: "action.delete".localized, image: UIImage(systemName: "trash.fill"), attributes: .destructive) { [weak self] (_) in
                    self?.removeClient(client, at: indexPath)
                }

                return UIMenu(title: "", children: [removeFinishedAction, editAction, deleteAction])
            }
            
        case .results:
            let result = searchResults[indexPath.row]
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
                let shareAction = UIAction(title: "action.sharelink".localized, image: UIImage(systemName: "square.and.arrow.up")) { [weak self] (_) in
                    guard let cell = tableView.cellForRow(at: indexPath) else { return }
                    self?.shareResult(result, from: cell)
                }
                let openAction = UIAction(title: "action.open".localized, image: UIImage(systemName: "safari")) { [weak self] (_) in
                    self?.openResultInSafari(result)
                }

                return UIMenu(title: "", children: [openAction, shareAction])
            }
        }
    }
    
    #if !targetEnvironment(macCatalyst) && os(iOS)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if #available(iOS 13.0, *) {
            return []
        }
        
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return [] }
        switch tableSection {
        case .buttons:
            return []
            
        case .clients:
            let client = clients[indexPath.row]
            let removeFinishedAction = UITableViewRowAction(style: .normal, title: "action.removefinished".localized) { [weak self] (_, _) in
                self?.removeFinished(in: client)
            }
            removeFinishedAction.backgroundColor = .basicAction
            let editAction = UITableViewRowAction(style: .normal, title: "action.edit".localized) { [weak self] (_, _) in
                let vc = EditClientVC()
                vc.client = client
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            editAction.backgroundColor = .accent
            let deleteAction = UITableViewRowAction(style: .destructive, title: "action.delete".localized) { [weak self] (_, indexPath) in
                self?.removeClient(client, at: indexPath)
            }
            deleteAction.backgroundColor = .destructiveAction
            return [deleteAction, editAction, removeFinishedAction]
            
        case .results:
            let result = searchResults[indexPath.row]
            let openAction = UITableViewRowAction(style: .normal, title: "action.open".localized) { [weak self] (_, _) in
                self?.openResultInSafari(result)
            }
            openAction.backgroundColor = .basicAction
            let shareAction = UITableViewRowAction(style: .normal, title: "action.sharelink".localized) { [weak self] (_, indexPath) in
                guard let cell = tableView.cellForRow(at: indexPath) else { return }
                self?.shareResult(result, from: cell)
            }
            shareAction.backgroundColor = .accent
            return [shareAction, openAction]
        }
    }
    #endif
}
