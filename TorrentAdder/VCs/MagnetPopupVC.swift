//
//  MagnetPopupVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class MagnetPopupVC: ViewController {

    // MARK: Presentation
    static func show(in viewController: UIViewController, magnet: URL?, result: SearchResult?) {
        #if !targetEnvironment(macCatalyst) && os(iOS)
        guard Preferences.shared.clients.isNotEmpty else {
            UIAlertController.show(
                for: AppError.noClientsSaved,
                title: "error.title.cannotAddTorrent".localized,
                close: "action.close".localized,
                in: viewController
            )
            return
        }
        #endif

        let popupVC = MagnetPopupVC()
        popupVC.result = result
        popupVC.magnetURL = magnet
        
        popupVC.modalPresentationStyle = .popover
        popupVC.modalTransitionStyle = .crossDissolve
        popupVC.popoverPresentationController?.permittedArrowDirections = []
        popupVC.popoverPresentationController?.sourceView = viewController.view
        popupVC.popoverPresentationController?.sourceRect = viewController.view.bounds
        popupVC.popoverPresentationController?.delegate = popupVC

        UIView.transition(with: viewController.view.window ?? viewController.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            viewController.present(popupVC, animated: false, completion: nil)
        }, completion: nil)
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        
        spinner.color = .tint
        
        tableView.registerCell(ClientCell.self)
        tableView.tableFooterView = UIView()
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.intrinsicContentSize), options: .new, context: nil)
        
        cancelButton.setTitle("action.cancel".localized, for: .normal)
        closeButton.setTitle("action.close".localized, for: .normal)
        
        for button in [cancelButton!, closeButton!] {
            button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            button.backgroundColor = .background
            button.setTitleColor(.tint, for: .normal)
            button.setTitleColor(.normalText, for: .highlighted)
            
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = .separator
            button.addSubview(separator)
            
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            separator.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
            separator.leftAnchor.constraint(equalTo: button.leftAnchor).isActive = true
            separator.rightAnchor.constraint(equalTo: button.rightAnchor).isActive = true
        }
        
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        
        updateForMode(.clients, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBackgroundBlur()
        
        transitionCoordinator?.animate(alongsideTransition: { (ctx) in
            self.blurView?.alpha = 1
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (ctx) in
            self.blurView?.alpha = 0
        }, completion: nil)
    }
    
    deinit {
        tableView?.removeObserver(self, forKeyPath: #keyPath(UITableView.intrinsicContentSize))
    }
    
    // MARK: Properties
    private var magnetURL: URL?
    private var result: SearchResult?
    private let clientKinds: [ClientCell.Kind] = {
        var kinds = Preferences.shared.clients.map { ClientCell.Kind.client($0) }
        #if targetEnvironment(macCatalyst)
        kinds.insert(.openURL, at: 0)
        #endif
        return kinds
    }()
    private var canClose: Bool = false

    // MARK: Views
    private var blurView: UIVisualEffectView?
    @IBOutlet private var statusContainerView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var spinner: UIActivityIndicatorView!
    @IBOutlet private var buttonsStackView: UIStackView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    
    // MARK: Actions
    @IBAction private func closeButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: API
    private func fetchMagnetURLAndAdd(to clientKind: ClientCell.Kind) {
        guard let url = (magnetURL ?? result?.magnetURL) else { return }
        
        switch clientKind {
        case .newClient:
            break

        case .client(let client), .discoveredClient(let client, _):
            if let client = client {
                updateForMode(.loading, animated: true)
                addMagnetToClient(magnetURL: url, client: client)
            }

        case .openURL:
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func addMagnetToClient(magnetURL: URL, client: Client) {
        updateForMode(.loading, animated: true)
        
        ClientAPI.shared.addMagnet(magnetURL, to: client)
            .onSuccess { message in
                var successMessage = "torrent.success".localized
                if let message = message, !message.isEmpty {
                    successMessage += "\n\n" + "torrent.success.messagefrom %@".localized(client.name) + message
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
    
    private func addBackgroundBlur() {
        guard let transitionView = popoverPresentationController?.containerView, blurView == nil else { return }

        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        effectView.frame = transitionView.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = 0
        transitionView.addSubview(effectView)
        transitionView.sendSubviewToBack(effectView)

        blurView = effectView
    }
    
    private func updateForMode(_ mode: Mode, animated: Bool) {
        if animated {
            view.layoutIfNeeded()
            UIView.transition(with: view, duration: 0.3, options: [.transitionCrossDissolve, .layoutSubviews], animations: {
                self.updateForMode(mode, animated: false)
                self.buttonsStackView.layoutIfNeeded()
                self.buttonsStackView.arrangedSubviews.forEach { $0.layoutIfNeeded() }
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
            
            cancelButton.sy_isHidden = false
            closeButton.sy_isHidden = true

        case .loading:
            canClose = false
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            statusLabel.text = "torrent.loading".localized
            spinner.sy_isHidden = false
            spinner.startAnimating()
            
            cancelButton.sy_isHidden = true
            closeButton.sy_isHidden = true

        case .success(let message):
            canClose = true
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            spinner.stopAnimating()
            spinner.sy_isHidden = true
            statusLabel.text = message
            
            cancelButton.sy_isHidden = true
            closeButton.sy_isHidden = false

        case .failure(let error):
            canClose = false
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            spinner.stopAnimating()
            spinner.sy_isHidden = true
            statusLabel.text = error
            
            cancelButton.sy_isHidden = true
            closeButton.sy_isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.updateForMode(.clients, animated: true)
            }
        }
    }
    
    // MARK: Layout
    private func updatePopover() {
        guard let window = view.window else { return }
        preferredContentSize.width  = min(320, max(500, window.bounds.width - 40))
        preferredContentSize.height = min(500, max(300, tableView.contentSize.height + buttonsStackView.frame.height))
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

extension MagnetPopupVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientKinds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ClientCell.self, for: indexPath)
        cell.kind = clientKinds[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return result?.name ?? magnetURL?.magnetName?.capitalized
    }
}

extension MagnetPopupVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        fetchMagnetURLAndAdd(to: clientKinds[indexPath.row])
    }
}

extension MagnetPopupVC : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

