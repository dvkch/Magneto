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
        navigationItem.rightBarButtonItems = [loaderBarButtonItem]

        resultsVC.delegate = self
        resultsVC.searchController = searchController
        searchController.searchResultsUpdater = resultsVC
        searchController.searchBar.delegate = resultsVC
        searchController.searchBar.placeholder = "placeholder.search".localized
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
            tableView: tableView, sectionTitle: "clients.section.clients".localized,
            showAdd: true, showMagnet: false
        )
        tableView.separatorStyle = .singleLine // force their appearance on catalyst
        tableView.dataSource = dataSource
        tableView.backgroundColor = .background
        tableView.registerCell(ClientCell.self)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        
        helpButton.clipsToBounds = true
        helpButton.accessibilityLabel = "alert.help.title".localized
        helpButton.backgroundColor = .tint
        helpButton.setBackgroundColor(.altText, for: .highlighted)
        helpButton.tintColor = .normalTextOnTint
        helpButton.layer.cornerRadius = 16
        helpButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
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
    private let loaderBarButtonItem: UIBarButtonItem = .loader(color: .normalTextOnTint)
    private let resultsVC = ResultsVC()
    private lazy var searchController = UISearchController(searchResultsController: resultsVC)
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var helpButton: UIButton!
    
    // MARK: Actions
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
    
    fileprivate func removeFinished(in client: Client) {
        let hud = HUDAlertController.show(in: self)
        ClientAPI.shared.removeCompletedTorrents(in: client)
            .andThen { _ in HUDAlertController.dismiss(hud, animated: false) }
            .onSuccess { (count) in
                if count > 0 {
                    UIAlertController.show(title: "torrent.removed.%d".localized(quantity: count), close: "action.close".localized, in: self)
                }
            }
            .onFailure { error in
                UIAlertController.show(for: error, close: "action.close".localized, in: self)
            }
    }
    
    fileprivate func removeClient(_ client: Client, confirmed: Bool, sender: UIView?) {
        if !confirmed {
            let alert = UIAlertController(
                title: "alert.client.delete.title".localized,
                message: "alert.client.delete.message %@".localized(client.name),
                preferredStyle: .alert
            )
            alert.addAction(title: "action.delete".localized, style: .destructive) { _ in
                self.removeClient(client, confirmed: true, sender: sender)
            }
            alert.addAction(title: "action.cancel".localized, style: .cancel, handler: nil)
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

        let removeFinishedAction = Action(title: "action.removefinished".localized, icon: .empty, color: .cellBackgroundAlt) { [weak self] in
            self?.removeFinished(in: client)
        }
        let editAction = Action(title: "action.edit".localized, icon: .edit, color: .tint) { [weak self] in
            let vc = EditClientVC(client: client)
            self?.present(NavigationController(rootViewController: vc), animated: true)
        }
        let deleteAction = Action(title: "action.delete".localized, icon: .delete, color: .leechers, destructive: true) { [weak self] in
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
