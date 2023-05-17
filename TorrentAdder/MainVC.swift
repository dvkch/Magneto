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

class MainVC: ViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Bundle.main.localizedName
        navigationItem.rightBarButtonItems = [mirrorBarButtonItem, loaderBarButtonItem]
        (navigationController as? NavigationController)?.useClearNavBarBackground = true

        let constraint = tableViewBackground.topAnchor.constraint(equalTo: searchField.bottomAnchor)
        constraint.priority = .defaultHigh
        constraint.isActive = true

        NotificationCenter.default.addObserver(self, selector: #selector(self.mirrorsChanged), name: .mirrorsChanged, object: nil)

        timerRefreshClientsStatus = Timer(timeInterval: 5, target: self, selector: #selector(self.timerRefreshClientsStatusTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timerRefreshClientsStatus!, forMode: .common)

        mirrorsChanged()

        searchField.textField?.backgroundColor = .fieldBackground
        searchField.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchField.keyboardType = .default
        searchField.placeholder = "placeholder.search".localized
        
        tableView.registerCell(ClientCell.self)
        tableView.registerCell(ResultCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        
        // make sure the list has an initial value at init time, in case the app is opened from a magnet
        clients = Preferences.shared.clients
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    private var showingSearch: Bool { return !searchQuery.isEmpty }
    private weak var suggestionsVC: SuggestionsVC?
    private var isLoadingResults: Bool = false {
        didSet {
            updateNavigationItems()
        }
    }
    
    // MARK: Views
    private let loaderBarButtonItem: UIBarButtonItem = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .normalTextOnTint
        return UIBarButtonItem(customView: spinner)
    }()
    private var mirrorBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "icloud"), menu: nil)
    @IBOutlet private var searchField: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var tableViewBackground: UIView!
    @IBOutlet private var helpButton: HelpButton!
    
    private func updateNavigationItems() {
        // loader
        if isLoadingResults {
            (loaderBarButtonItem.customView as? UIActivityIndicatorView)?.startAnimating()
        }
        else {
            (loaderBarButtonItem.customView as? UIActivityIndicatorView)?.stopAnimating()
        }
        
        // mirrors
        var mirrorMenus = [UIMenu]()
        
        if let mirror = WebAPI.shared.availableMirrorURLs.first {
            mirrorMenus.append(UIMenu(title: "mirror.current %@".localized(mirror.host ?? ""), options: .displayInline, children: [
                UIAction(title: "action.open".localized) { _ in
                    self.openSafariURL(mirror)
                },
                UIAction(title: "alert.mirror.blacklist_mirror".localized) { _ in
                    Preferences.shared.mirrorBlacklist.append(mirror)
                    WebAPI.shared.clearMirrors()
                }
            ]))
        }
        else {
            mirrorMenus.append(UIMenu(title: "mirror.none".localized))
        }

        mirrorMenus.append(UIMenu(title: "alert.mirror.title".localized, options: .displayInline, children: [
            UIAction(title: "alert.mirror.clean_mirror_blacklist".localized) { _ in
                Preferences.shared.mirrorBlacklist = []
                WebAPI.shared.clearMirrors()
            }
        ]))
        
        mirrorBarButtonItem.menu = UIMenu(children: mirrorMenus)
    }
    
    // MARK: Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        helpButton.layer.cornerRadius = helpButton.bounds.height / 2
    }
}

// MARK: Notifications
extension MainVC {
    @objc private func mirrorsChanged() {
        updateNavigationItems()
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
            isLoadingResults = false
            return
        }
        
        isLoadingResults = true
        _ = WebAPI.shared.getResults(query: text)
            .andThen { [weak self] result in
                
                guard let self = self else { return }
                guard self.searchQuery == text else { return }
                
                self.isLoadingResults = false

                switch result {
                case .success(let items):
                    self.searchResults = items
                    self.tableView.reloadData()
                    self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
                    Preferences.shared.addPrevSearch(text)
                    
                case .failure(let error):
                    UIAlertController.show(for: error, title: "error.title.cannotLoadResults".localized, close: "action.close".localized, in: self)
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
            UIAlertController.show(for: AppError.noClientsSaved, title: "error.title.cannotAddTorrent".localized, close: "action.close".localized, in: self)
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
        vc.preferredBarTintColor = UIColor.tint.resolvedColor(with: traitCollection)
        vc.preferredControlTintColor = UIColor.normalText.resolvedColor(with: traitCollection)
        present(vc, animated: true, completion: nil)
        #endif
    }
    
    fileprivate func removeFinished(in client: Client) {
        let hud = HUDAlertController.show(in: self)
        ClientAPI.shared.removeCompletedTorrents(in: client)
            .andThen { _ in HUDAlertController.dismiss(hud, animated: false) }
            .onSuccess { (count) in
                if count > 0 {
                    UIAlertController.show(title: String(format: "torrent.removed.%d".localized, count), close: "action.close".localized, in: self)
                }
            }
            .onFailure { error in
                UIAlertController.show(for: error, close: "action.close".localized, in: self)
            }
    }
    
    fileprivate func removeClient(_ client: Client, at indexPath: IndexPath) {
        Preferences.shared.removeClient(client)
        clients = Preferences.shared.clients
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
        tableView.endUpdates()
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

extension MainVC : UITableViewDataSource {
    enum TableSection : Int, CaseIterable {
        case clients, results
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = TableSection(rawValue: section) else { return 0 }
        switch tableSection {
        case .clients: return showingSearch ? 0 : clients.count + 1
        case .results: return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tableSection = TableSection(rawValue: section) else { return nil }
        switch tableSection {
        case .clients: return showingSearch ? nil : "clients.section.clients".localized
        case .results:
            if !showingSearch { return nil }
            return searchResults.isEmpty ? "clients.section.noresults".localized : "clients.section.results".localized
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch tableSection {
        case .clients:
            let cell = tableView.dequeueCell(ClientCell.self, for: indexPath)
            if indexPath.row < clients.count {
                cell.kind = .client(clients[indexPath.row])
            }
            else {
                cell.kind = .newClient
            }
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
        case .clients:
            if indexPath.row < clients.count {
                let client = clients[indexPath.row]
                var url = client.webURL
                if let username = client.username?.nilIfEmpty, let password = client.password?.nilIfEmpty, var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                    components.user = username
                    components.password = password
                    url = components.url ?? url
                }
                self.openSafariURL(url)
            }
            else {
                let vc = DiscoverClientsVC()
                let nc = NavigationController(rootViewController: vc)
                present(nc, animated: true, completion: nil)
            }

        case .results:
            self.openTorrentPopup(with: nil, or: searchResults[indexPath.row])
        }
    }
    
    private struct Action {
        let title: String
        let image: String
        let color: UIColor
        let destructive: Bool
        let closure: () -> ()
        
        init(title: String, image: String, color: UIColor = .tint, destructive: Bool = false, closure: @escaping () -> Void) {
            self.title = title
            self.image = image
            self.color = color
            self.destructive = destructive
            self.closure = closure
        }
    }
    
    private func actionsForRow(at indexPath: IndexPath) -> [Action] {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return [] }

        switch tableSection {
        case .clients:
            let client = clients[indexPath.row]
            let removeFinishedAction = Action(title: "action.removefinished".localized, image: "tray.and.arrow.up", color: .cellBackgroundAlt) { [weak self] in
                self?.removeFinished(in: client)
            }
            let editAction = Action(title: "action.edit".localized, image: "pencil", color: .tint) { [weak self] in
                let vc = EditClientVC()
                vc.client = client
                self?.present(vc, animated: true)
            }
            let deleteAction = Action(title: "action.delete".localized, image: "trash", color: .leechers, destructive: true) { [weak self] in
                self?.removeClient(client, at: indexPath)
            }
            return [removeFinishedAction, editAction, deleteAction]
            
        case .results:
            let result = searchResults[indexPath.row]
            let shareAction = Action(title: "action.sharelink".localized, image: "square.and.arrow.up", color: .cellBackgroundAlt) { [weak self] in
                guard let cell = self?.tableView.cellForRow(at: indexPath) else { return }
                self?.shareResult(result, from: cell)
            }
            let openAction = Action(title: "action.open".localized, image: "safari", color: .tint) { [weak self] in
                self?.openResultInSafari(result)
            }
            return [openAction, shareAction]
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let actions = self.actionsForRow(at: indexPath).map { action in
                UIAction(title: action.title, image: UIImage(systemName: action.image), attributes: action.destructive ? .destructive : []) { _ in
                    action.closure()
                }
            }
            return UIMenu(title: "", children: actions)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actions = self.actionsForRow(at: indexPath).reversed().map { action in
            let contextualAction = UIContextualAction(style: action.destructive ? .destructive : .normal, title: action.title) { _, _, completed in
                action.closure()
                completed(true)
            }
            contextualAction.image = UIImage(systemName: action.image)
            contextualAction.backgroundColor = action.color
            return contextualAction
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
}
