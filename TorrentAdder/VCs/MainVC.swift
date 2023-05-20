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
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [mirrorBarButtonItem, loaderBarButtonItem]

        resultsVC.delegate = self
        searchController.searchResultsUpdater = resultsVC
        searchController.searchBar.delegate = resultsVC
        searchController.searchBar.placeholder = "placeholder.search".localized
        searchController.searchBar.keyboardType = .default
        searchController.searchBar.textField?.backgroundColor = .fieldBackground
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        
        tableView.dataSource = dataSource
        tableView.backgroundColor = .background
        tableView.registerCell(ClientCell.self)
        tableView.registerCell(ResultCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        
        helpButton.clipsToBounds = true
        helpButton.accessibilityLabel = "alert.help.title".localized
        helpButton.backgroundColor = .tint
        helpButton.setBackgroundColor(.altText, for: .highlighted)
        helpButton.tintColor = .normalTextOnTint
        helpButton.layer.cornerRadius = 16
        helpButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshClients), name: .clientsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshClients), name: .clientStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMirrorsButton), name: .mirrorsChanged, object: nil)
        
        DispatchQueue.main.async {
            self.refreshClients(animated: false)
            self.refreshMirrorsButton()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Properties
    private lazy var dataSource: ClientsDataSources = .init(tableView: tableView)
    
    // MARK: Views
    private let loaderBarButtonItem: UIBarButtonItem = .loader(color: .normalTextOnTint)
    private let mirrorBarButtonItem: UIBarButtonItem = .init(image: .icon(.cloud), menu: nil)
    private let resultsVC = ResultsVC()
    private lazy var searchController = UISearchController(searchResultsController: resultsVC)
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var helpButton: UIButton!
    
    // MARK: Content
    @objc private func refreshMirrorsButton() {
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
    
    @objc private func refreshClients(animated: Bool = true) {
        let clientsWithPosition = Preferences.shared.clients.map {
            let statusPosition: Int
            switch ClientStatusManager.shared.statusForClient($0) {
            case .online:  statusPosition = 0
            case .unknown: statusPosition = 1
            case .offline: statusPosition = 2
            }
            return ($0, "\(statusPosition)-\($0.name.uppercased())")
        }

        let sortedClients = clientsWithPosition.sorted(by: \.1).map(\.0)
        dataSource.update(with: sortedClients, showAdd: true, animated: animated)
    }

    // MARK: Actions
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
            preferredStyle: .actionSheet
        )
        alert.addAction(title: "action.close".localized, style: .cancel, handler: nil)
        alert.popoverPresentationController?.sourceView = helpButton
        alert.popoverPresentationController?.sourceRect = helpButton.bounds
        present(alert, animated: true, completion: nil)
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
        refreshClients()
    }
    
    // MARK: Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView?.frame.size = searchController.searchBar.intrinsicContentSize
    }
}

extension MainVC : ResultsVCDelegate {
    func resultsVC(_ resultsVC: ResultsVC, isLoading: Bool) {
        if isLoading {
            (loaderBarButtonItem.customView as? UIActivityIndicatorView)?.startAnimating()
        }
        else {
            (loaderBarButtonItem.customView as? UIActivityIndicatorView)?.stopAnimating()
        }
    }
}

extension MainVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = dataSource.itemIdentifier(for: indexPath) ?? .newClient
        if let client = item.client {
            openSafariURL(client.webURLWithAuth)
        }
        else {
            let vc = DiscoverClientsVC()
            let nc = NavigationController(rootViewController: vc)
            present(nc, animated: true, completion: nil)
        }
    }
    
    private func actionsForRow(at indexPath: IndexPath) -> [Action] {
        let item = dataSource.itemIdentifier(for: indexPath) ?? .newClient
        guard let client = item.client else { return [] }

        let removeFinishedAction = Action(title: "action.removefinished".localized, icon: .empty, color: .cellBackgroundAlt) { [weak self] in
            self?.removeFinished(in: client)
        }
        let editAction = Action(title: "action.edit".localized, icon: .edit, color: .tint) { [weak self] in
            let vc = EditClientVC(client: client)
            self?.present(NavigationController(rootViewController: vc), animated: true)
        }
        let deleteAction = Action(title: "action.delete".localized, icon: .delete, color: .leechers, destructive: true) { [weak self] in
            self?.removeClient(client, at: indexPath)
        }
        return [removeFinishedAction, editAction, deleteAction]
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
