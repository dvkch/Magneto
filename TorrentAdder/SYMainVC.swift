//
//  SYMainVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit
import SYPopoverController
import SafariServices
import SVProgressHUD

class SYMainVC: UIViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidOpenURLNotification(_:)), name: .didOpenURL, object: nil)
        
        timerRefreshClientsStatus = Timer(timeInterval: 5, target: self, selector: #selector(self.timerRefreshClientsStatusTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timerRefreshClientsStatus!, forMode: .common)

        titleLabel.addGlow(color: .lightGray, size: 4)

        spinner.radius = 13
        spinner.strokeColor = .white
        spinner.strokeThickness = 3
        spinner.isHidden = true

        searchField.sy_textField?.backgroundColor = .init(white: 1, alpha: 0.4)
        searchField.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchField.keyboardType = .default
        searchField.placeholder = "Search"
        
        tableView.registerCell(SYAddClientCell.self)
        tableView.registerCell(SYClientCell.self)
        tableView.registerCell(SYResultCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        
        helpButton.tintColor = .lightBlue
        
        constraintHeaderHeightOriginalValue = constraintHeaderHeight.constant
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
    @IBOutlet private var helpButton: SYButton!
}

// MARK: Notifications
extension SYMainVC {
    
    @objc private func appDidOpenURLNotification(_ notif: Notification) {
        guard let magnetURL = notif.userInfo?[UIApplication.DidOpenURLKey.magnetURL] as? URL else { return }
        let appID = notif.userInfo?[UIApplication.DidOpenURLKey.appID] as? String

        openTorrentPopup(with: magnetURL, or: nil, sourceApp: SYSourceApp(bundleId: appID))
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
            title: "Help",
            message: "To add a torrent you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select a client to start downloading the torrent.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
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
                    self.showError(error, title: "Cannot load results")
                }
        }
    }
    
    fileprivate func openTorrentPopup(with magnetURL: URL?, or result: SYSearchResult?, sourceApp: SYSourceApp?) {
        guard !clients.isEmpty else {
            showError(SYError.noClientsSaved, title: "Cannot add torrent")
            return
        }
        
        SYMagnetPopupVC.show(in: self, magnet: magnetURL, result: result, sourceApp: sourceApp)
    }
    
    fileprivate func removeFinished(in client: SYClient) {
        SVProgressHUD.show()
        SYClientAPI.shared.removeCompletedTorrents(in: client)
            .andThen { _ in SVProgressHUD.dismiss() }
            .onSuccess { (count) in SVProgressHUD.showSuccess(withStatus: "Removed \(count) finished items") }
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
        if searchText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
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
        case .buttons: return showingSearch ? nil : "Available clients"
        case .clients: return nil
        case .results:
            if !showingSearch { return nil }
            return searchResults.isEmpty ? "No results" : "Results"
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
            let url = clients[indexPath.row].webURL
            let vc = SFSafariViewController(url: url)
            if #available(iOS 10, *) {
                vc.preferredBarTintColor = .lightBlue
            }
            present(vc, animated: true, completion: nil)

        case .results:
            self.openTorrentPopup(with: nil, or: searchResults[indexPath.row], sourceApp: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return nil }
        switch tableSection {
        case .buttons:
            return nil
            
        case .clients:
            let client = clients[indexPath.row]
            let removeFinishedAction = UITableViewRowAction(style: .normal, title: "Remove finished") { [weak self] (_, _) in
                self?.removeFinished(in: client)
            }
            let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (_, _) in
                let vc = SYEditClientVC()
                vc.client = client
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            editAction.backgroundColor = .lightBlue
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (_, indexPath) in
                self?.removeClient(client, at: indexPath)
            }
            return [deleteAction, editAction, removeFinishedAction]
            
        case .results:
            let result = searchResults[indexPath.row]
            let shareAction = UITableViewRowAction(style: .normal, title: "Share page link") { [weak self] (_, indexPath) in
                self?.shareResult(result, from: tableView.cellForRow(at: indexPath))
            }
            shareAction.backgroundColor = UIColor(red: 14/255, green: 162/255, blue: 1, alpha: 1)
            return [shareAction]
        }
    }
}
