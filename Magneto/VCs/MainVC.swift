//
//  MainVC.swift
//  Magneto
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
        navigationItem.rightBarButtonItems = [searchAPIButtonItem, loaderBarButtonItem]
        
        searchAPIButtonItem.title = L10n.searchApi

        resultsVC.delegate = self
        resultsVC.searchController = searchController
        searchController.searchResultsUpdater = resultsVC
        searchController.searchBar.delegate = resultsVC
        searchController.searchBar.placeholder = L10n.Placeholder.search
        searchController.searchBar.keyboardType = .default
        searchController.searchBar.searchTextField.backgroundColor = .fieldBackground
        searchController.searchBar.searchTextField.layer.cornerRadius = 5
        searchController.searchBar.searchTextField.clipsToBounds = true

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        
        dataSource = .init(
            tableView: tableView, sectionTitle: L10n.Clients.Section.clients,
            showAdd: true, showMagnet: false
        )
        tableView.separatorStyle = .singleLine // force their appearance on catalyst
        tableView.dataSource = dataSource
        tableView.backgroundColor = .background
        tableView.registerCell(ClientCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        
        helpButton.clipsToBounds = true
        helpButton.accessibilityLabel = L10n.Alert.Help.title
        helpButton.backgroundColor = .tint
        helpButton.setBackgroundColor(.altText, for: .highlighted)
        helpButton.tintColor = .normalTextOnTint
        helpButton.layer.cornerRadius = 16
        helpButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        NotificationCenter.default.addObserver(self, selector: #selector(searchAPIChanged), name: .searchAPIChanged, object: nil)
        searchAPIChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearOnce = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Properties
    private var dataSource: ClientsDataSources!
    private var viewDidAppearOnce: Bool = false
    
    // MARK: Views
    private let searchAPIButtonItem: UIBarButtonItem = .init()
    private let loaderBarButtonItem: UIBarButtonItem = .loader(color: .normalTextOnTint)
    private let resultsVC = ResultsVC()
    private lazy var searchController = UISearchController(searchResultsController: resultsVC)
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var helpButton: UIButton!
    
    // MARK: Actions
    @objc private func searchAPIChanged() {
        let apis = SearchAPIKind.allCases.map { kind in
            let action = UIAction(title: kind.title, image: .icon(kind.icon), attributes: []) { _ in
                Preferences.shared.searchAPI = kind
            }
            action.state = Preferences.shared.searchAPI == kind ? .on : .off
            return action
        }
        searchAPIButtonItem.menu = UIMenu(title: L10n.searchApi, children: apis)
        searchAPIButtonItem.image = .icon(Preferences.shared.searchAPI.icon)
    }

    @IBAction private func helpButtonTap() {
        let alert = UIAlertController(
            title: L10n.Alert.Help.title,
            message: L10n.Alert.Help.message,
            preferredStyle: .actionSheet
        )
        alert.addAction(title: L10n.Action.close, style: .cancel, handler: nil)
        alert.popoverPresentationController?.sourceView = helpButton
        alert.popoverPresentationController?.sourceRect = helpButton.bounds
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func removeFinished(in client: Client) {
        let hud = HUDAlertController.show(in: self)
        TransmissionAPI.shared.removeCompletedTorrents(in: client)
            .andThen { _ in HUDAlertController.dismiss(hud, animated: false) }
            .delay(.milliseconds(200))
            .onSuccess { (count) in
                if count > 0 {
                    UIAlertController.show(title: L10n.Torrent.Removed.quantity(count), close: L10n.Action.close, in: self)
                }
            }
            .onFailure { error in
                UIAlertController.show(for: error, close: L10n.Action.close, in: self)
            }
    }
    
    fileprivate func removeClient(_ client: Client, confirmed: Bool, sender: UIView?) {
        if !confirmed {
            let alert = UIAlertController(
                title: L10n.Alert.Client.Delete.title,
                message: L10n.Alert.Client.Delete.message(client.name),
                preferredStyle: .alert
            )
            alert.addAction(title: L10n.Action.delete, style: .destructive) { _ in
                self.removeClient(client, confirmed: true, sender: sender)
            }
            alert.addAction(title: L10n.Action.cancel, style: .cancel, handler: nil)
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender?.bounds ?? .zero
            present(alert, animated: true)
            return
        }

        Preferences.shared.removeClient(client)
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

        let removeFinishedAction = Action(title: L10n.Action.removefinished, icon: .empty, color: .cellBackgroundAlt) { [weak self] in
            self?.removeFinished(in: client)
        }
        let editAction = Action(title: L10n.Action.edit, icon: .edit, color: .tint) { [weak self] in
            let vc = EditClientVC(client: client)
            self?.present(NavigationController(rootViewController: vc), animated: true)
        }
        let deleteAction = Action(title: L10n.Action.delete, icon: .delete, color: .leechers, destructive: true) { [weak self] in
            self?.removeClient(client, confirmed: false, sender: self?.tableView.cellForRow(at: indexPath))
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
