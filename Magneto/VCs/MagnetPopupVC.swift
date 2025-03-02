//
//  MagnetPopupVC.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit
import BrightFutures

class MagnetPopupVC: ViewController {

    // MARK: Presentation
    static func show(in viewController: UIViewController, source: Source, sender: UIView?) {
        #if !targetEnvironment(macCatalyst) && os(iOS)
        guard Preferences.shared.clients.isNotEmpty else {
            UIAlertController.show(
                for: AppError.noClientsSaved,
                title: L10n.Error.Title.cannotAddTorrent,
                close: L10n.Action.close,
                in: viewController
            )
            return
        }
        #endif

        let popupVC = MagnetPopupVC()
        popupVC.source = source
        
        popupVC.modalPresentationStyle = .popover
        if let sender {
            popupVC.popoverPresentationController?.permittedArrowDirections = [.any]
            popupVC.popoverPresentationController?.sourceView = sender
            popupVC.popoverPresentationController?.sourceRect = sender.bounds
        }
        else if !UIDevice.isCatalyst {
            popupVC.popoverPresentationController?.permittedArrowDirections = []
            popupVC.popoverPresentationController?.sourceView = viewController.view
            popupVC.popoverPresentationController?.canOverlapSourceViewRect = true
            popupVC.popoverPresentationController?.sourceRect = viewController.view.bounds
        }
        else {
            popupVC.modalPresentationStyle = .pageSheet
        }
        popupVC.popoverPresentationController?.delegate = popupVC
        viewController.present(popupVC, animated: true, completion: nil)
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = source.name

        spinner.color = .tint
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        
        clientsDataSource = .init(tableView: tableView, sectionTitle: nil, showAdd: false, showMagnet: UIDevice.isCatalyst)
        tableView.registerCell(ClientCell.self)
        tableView.dataSource = clientsDataSource
        tableView.tableFooterView = UIView()
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.intrinsicContentSize), options: .new, context: nil)
        
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        
        updateForMode(.clients, animated: false)
        
        addKeyCommand(.init(
            title: L10n.Action.close,
            action: #selector(closeButtonTap),
            input: UIKeyCommand.inputEscape,
            modifierFlags: .init()
        ))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popoverPresentationController?.backgroundColor = .darkGray
        view.backgroundColor = .darkGray // setting it earlier doesn't work ¯\_(ツ)_/¯
    }
    
    deinit {
        tableView?.removeObserver(self, forKeyPath: #keyPath(UITableView.intrinsicContentSize))
    }
    
    // MARK: Properties
    enum Source {
        case resolved(Torrent)
        case result(any SearchResult, any SearchResultVariant)

        func get() -> Future<Torrent, AppError> {
            switch self {
            case .resolved(let torrent):    return .init(value: torrent)
            case .result(_, let r):         return r.torrent()
            }
        }
        
        var name: String? {
            switch self {
            case .resolved(let torrent):
                return torrent.name
            case .result(let r, let v):
                if r.name == v.name {
                    return v.name
                }
                return "\(r.name) (\(v.name))"
            }
        }
    }
    private var source: Source!
    private var clientsDataSource: ClientsDataSources!
    private var canClose: Bool = false

    // MARK: Views
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var statusContainerView: UIView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var spinner: UIActivityIndicatorView!
    
    // MARK: Actions
    @objc private func closeButtonTap() {
        dismiss(animated: true)
    }
    
    // MARK: API
    private func fetchMagnetURLAndAdd(to clientKind: ClientCell.Kind) {
        updateForMode(.loading, animated: true)
        source.get().onSuccess { torrent in
                switch clientKind {
                case .newClient:
                    break

                case .client(let client), .discoveredClient(let client, _):
                    if let client {
                        self.addTorrentToClient(torrent: torrent, client: client)
                    }

                case .openURL:
                    switch torrent {
                    case .url(let url):
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    case .base64(let url, let base64):
                        #if targetEnvironment(macCatalyst)
                        if #available(macCatalyst 16.0, *) {
                            let tempURL = FileManager.default.temporaryDirectory.appending(component: url.absoluteString.sha256String + ".torrent")
                            do {
                                try Data(base64Encoded: base64)?.write(to: tempURL)
                                UIApplication.shared.open(tempURL, options: [:], completionHandler: nil)
                            }
                            catch {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        } else {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                        #else
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        #endif
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
            .onFailure { error in
                self.updateForMode(.failure(error.localizedDescription), animated: true)
            }
    }
    
    private func addTorrentToClient(torrent: Torrent, client: Client) {
        updateForMode(.loading, animated: true)
        
        TransmissionAPI.shared.addTorrent(torrent, to: client)
            .onSuccess { message in
                var successMessage = L10n.Torrent.success
                if let message = message, !message.isEmpty {
                    successMessage += "\n\n" + L10n.Torrent.Success.messagefrom(client.name) + message
                }
                self.updateForMode(.success(successMessage), animated: true)
            }
            .onFailure { error in
                let errorMessage = (error.isOfflineError ? AppError.clientOffline : error).localizedDescription
                self.updateForMode(.failure(errorMessage), animated: true)
            }
    }
    
    // MARK: Content
    enum Mode {
        case clients, loading, success(_ message: String), failure(_ error: String)
    }
    
    private func updateForMode(_ mode: Mode, animated: Bool) {
        if animated {
            view.layoutIfNeeded()
            UIView.transition(with: view, duration: 0.3, options: [.transitionCrossDissolve, .layoutSubviews], animations: {
                self.updateForMode(mode, animated: false)
            }, completion: nil)
            return
        }
        
        switch mode {
        case .clients:
            canClose = true
            tableView.alpha = 1
            statusContainerView.alpha = 0
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: false)
            }

        case .loading:
            canClose = false
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            statusLabel.text = L10n.Torrent.loading
            spinner.sy_isHidden = false
            spinner.startAnimating()

        case .success(let message):
            canClose = true
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            spinner.stopAnimating()
            spinner.sy_isHidden = true
            statusLabel.text = message

        case .failure(let error):
            canClose = false
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            spinner.stopAnimating()
            spinner.sy_isHidden = true
            statusLabel.text = error
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.updateForMode(.clients, animated: true)
            }
        }
    }
    
    // MARK: Layout
    private func updatePopover() {
        guard let window = view.window else { return }
        preferredContentSize.width  = (window.bounds.width - 40).clamped(min: 300, max: 500)
        preferredContentSize.height = (titleLabel.frame.height + 2 * 8 + tableView.contentSize.height).clamped(min: 50, max: 500)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? UITableView) == tableView && keyPath == #keyPath(UITableView.contentSize) {
            updatePopover()
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
        updatePopover()
    }
}

extension MagnetPopupVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let client = clientsDataSource.itemIdentifier(for: indexPath) else { return }
        fetchMagnetURLAndAdd(to: client)
    }
}

extension MagnetPopupVC : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return canClose
    }
}
