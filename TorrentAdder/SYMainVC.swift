//
//  SYMainVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit
import SafariServices
import SVProgressHUD
import SYPopoverController

class SYMainVC: ViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidOpenURLNotification(_:)), name: .didOpenURL, object: nil)
        
        timerRefreshClientsStatus = Timer(timeInterval: 5, target: self, selector: #selector(self.timerRefreshClientsStatusTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timerRefreshClientsStatus!, forMode: .common)

        titleLabel.addGlow(color: .lightGray, size: 4)
        
        spinner.strokeColor = .textOverAccent
        spinner.radius = 13
        spinner.strokeThickness = 3
        spinner.isHidden = true

        searchField.textField?.backgroundColor = .fieldBackground
        searchField.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchField.keyboardType = .default
        searchField.placeholder = "placeholder.search".localized
        
        tableView.registerCell(SYAddClientCell.self)
        tableView.registerCell(SYClientCell.self)
        tableView.registerCell(SYResultCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        
        constraintHeaderHeightOriginalValue = constraintHeaderHeight.constant
        
        // make sure the list has an initial value at init time, in case the app is opened from a magnet
        clients = SYPreferences.shared.clients
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        clients = SYPreferences.shared.clients
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerRefreshClientsStatusTick()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didOpenURL, object: nil)
        timerRefreshClientsStatus?.invalidate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Properties
    private var timerRefreshClientsStatus: Timer?
    private var clients: [SYClient] = []
    private var searchResults: [SYSearchResult] = []
    private var searchQuery: String = ""
    private var constraintHeaderHeightOriginalValue: CGFloat = 0
    private var isVisible: Bool = false
    private var showingSearch: Bool { return !searchQuery.isEmpty }
    
    // MARK: Views
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var constraintHeaderHeight: NSLayoutConstraint!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var spinner: SVIndefiniteAnimatedView!
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
extension SYMainVC {
    
    @objc private func appDidOpenURLNotification(_ notif: Notification) {
        guard let magnetURL = notif.userInfo?[UIApplication.DidOpenURLKey.magnetURL] as? URL else { return }
        openTorrentPopup(with: magnetURL, or: nil)
    }
    
}

// MARK: Timer
extension SYMainVC {
    
    @objc private func timerRefreshClientsStatusTick() {
        if view.window == nil { return }
        clients.forEach {
            SYClientStatusManager.shared.startStatusUpdateIfNeeded(for: $0)
        }
    }
}

// MARK: Actions
extension SYMainVC {
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
        
        _ = SYWebAPI.shared.getResults(query: text)
            .andThen { [weak self] result in
                
                guard let self = self else { return }
                guard self.searchQuery == text else { return }
                
                self.spinner.isHidden = true

                switch result {
                case .success(let items):
                    self.searchResults = items
                    self.tableView.reloadData()
                    self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
                    
                case .failure(let error):
                    self.showError(error, title: "error.title.cannotLoadResults".localized)
                }
        }
    }
    
    fileprivate func openTorrentPopup(with magnetURL: URL?, or result: SYSearchResult?) {
        guard !clients.isEmpty else {
            showError(SYError.noClientsSaved, title: "error.title.cannotAddTorrent".localized)
            return
        }
        
        SYMagnetPopupVC.show(in: self, magnet: magnetURL, result: result)
    }
    
    fileprivate func removeFinished(in client: SYClient) {
        SVProgressHUD.show()
        SYClientAPI.shared.removeCompletedTorrents(in: client)
            .andThen { _ in SVProgressHUD.dismiss() }
            .onSuccess { (count) in SVProgressHUD.showSuccess(withStatus: String(format: "torrent.removed.%d".localized, count)) }
            .onFailure { error in self.showError(error) }
    }
    
    fileprivate func removeClient(_ client: SYClient, at indexPath: IndexPath) {
        SYPreferences.shared.removeClient(client)
        clients = SYPreferences.shared.clients
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
        tableView.endUpdates()
    }
    
    fileprivate func shareResult(_ result: SYSearchResult, from cell: UITableViewCell?) {
        SVProgressHUD.show()
        SYWebAPI.shared.getResultPageURL(result)
            .andThen { _ in SVProgressHUD.dismiss() }
            .onFailure { (error) in self.showError(error) }
            .onSuccess { (fullURL) in
                
                let vc = UIActivityViewController(activityItems: [fullURL], applicationActivities: nil)
                vc.popoverPresentationController?.sourceRect = cell?.frame ?? .zero
                vc.popoverPresentationController?.sourceView = self.view
                
                // TODO: use better sourceRect (centered ?) and arrowDirection
                self.present(vc, animated: true, completion: nil)
                self.tableView.setEditing(false, animated: true)
        }
    }
}

extension SYMainVC : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // when tapping the clear button we need to make sure the search results are also reset
        if searchText.isEmpty {
            updateSearch("")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        updateSearch(searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
}

extension SYMainVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        constraintHeaderHeight.constant = constraintHeaderHeightOriginalValue - min(0, scrollView.contentOffset.y)
    }
}

extension SYMainVC : UITableViewDataSource {
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
            let cell = tableView.dequeueCell(SYAddClientCell.self, for: indexPath)
            cell.clientsCount = clients.count
            cell.addButtonTapBlock = { [weak self] in
                let vc = SYDiscoverClientsVC()
                let nc = SYNavigationController(rootViewController: vc)
                self?.present(nc, animated: true, completion: nil)
            }
            return cell
        case .clients:
            let cell = tableView.dequeueCell(SYClientCell.self, for: indexPath)
            cell.client = clients[indexPath.row]
            cell.isDiscoveredClient = false
            return cell
        case .results:
            let cell = tableView.dequeueCell(SYResultCell.self, for: indexPath)
            cell.result = searchResults[indexPath.row]
            return cell
        }
    }
}

extension SYMainVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return 0 }
        switch tableSection {
        case .buttons: return 60
        case .clients: return 60
        case .results: return 80
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return 0 }
        switch tableSection {
        case .buttons: return 60
        case .clients: return 60
        case .results: return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return }
        switch tableSection {
        case .buttons:
            let vc = SYDiscoverClientsVC()
            let nc = SYNavigationController(rootViewController: vc)
            present(nc, animated: true, completion: nil)

        case .clients:
            let client = clients[indexPath.row]
            var url = client.webURL
            if let username = client.username?.nilIfEmpty, let password = client.password?.nilIfEmpty, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                components.user = username
                components.password = password
                url = components.url ?? url
            }
            let vc = SFSafariViewController(url: url)
            if #available(iOS 13.0, *) {
                vc.preferredBarTintColor = UIColor.accent.resolvedColor(with: traitCollection)
                vc.preferredControlTintColor = UIColor.text.resolvedColor(with: traitCollection)
            } else if #available(iOS 10, *) {
                vc.preferredBarTintColor = UIColor.accent
                vc.preferredControlTintColor = UIColor.text
            }
            present(vc, animated: true, completion: nil)

        case .results:
            self.openTorrentPopup(with: nil, or: searchResults[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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
                let vc = SYEditClientVC()
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
            let shareAction = UITableViewRowAction(style: .normal, title: "action.sharelink".localized) { [weak self] (_, indexPath) in
                self?.shareResult(result, from: tableView.cellForRow(at: indexPath))
            }
            shareAction.backgroundColor = .accent
            return [shareAction]
        }
    }
}
