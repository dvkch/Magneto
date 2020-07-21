//
//  MagnetPopupVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYPopoverController

class MagnetPopupVC: ViewController {

    // MARK: Presentation
    static func show(in viewController: UIViewController, magnet: URL?, result: SearchResult?) {
        let popupVC = MagnetPopupVC()
        popupVC.result = result
        popupVC.magnetURL = magnet
        
        let blur: UIBlurEffect.Style
        if #available(iOS 10.0, *) {
            blur = .prominent
        } else {
            blur = .light
        }
        viewController.sy_presentPopover(popupVC, backgroundEffect: UIBlurEffect(style: blur), animated: true, completion: nil)
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        
        spinner.color = .accent
        
        tableView.registerCell(ClientCell.self)
        tableView.tableFooterView = UIView()
        
        cancelButton.setTitle("action.cancel".localized, for: .normal)
        closeButton.setTitle("action.close".localized, for: .normal)
        
        for button in [cancelButton!, closeButton!] {
            button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            button.backgroundColor = .background
            button.setTitleColor(.accent, for: .normal)
            button.setTitleColor(.text, for: .highlighted)
            
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = .basicAction
            button.addSubview(separator)
            
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            separator.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
            separator.leftAnchor.constraint(equalTo: button.leftAnchor).isActive = true
            separator.rightAnchor.constraint(equalTo: button.rightAnchor).isActive = true
        }
        
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        
        clients = Preferences.shared.clients
        updateForMode(.clients, animated: false)
    }
    
    // MARK: Properties
    private var magnetURL: URL?
    private var result: SearchResult?
    private var clients = [Client]()
    private var canClose: Bool = false

    // MARK: Views
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
    private func fetchMagnetURLAndAdd(to client: Client) {
        guard let url = (magnetURL ?? result?.magnetURL) else { return }
        updateForMode(.loading, animated: true)
        addMagnetToClient(magnetURL: url, client: client)
    }
    
    private func addMagnetToClient(magnetURL: URL, client: Client) {
        updateForMode(.loading, animated: true)
        
        ClientAPI.shared.addMagnet(magnetURL, to: client)
            .onSuccess { message in
                var successMessage = "torrent.success".localized
                if let message = message, !message.isEmpty {
                    successMessage += "\n\n" + String(format: "torrent.success.messagefrom %@".localized, (client.name ?? client.host)) + message
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = CGSize(width: max(300, view.frame.size.width - 40), height: 400)
    }
}

extension MagnetPopupVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ClientCell.self, for: indexPath)
        cell.client = clients[indexPath.row]
        cell.isDiscoveredClient = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return result?.name ?? magnetURL?.magnetName?.capitalized
    }
}

extension MagnetPopupVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        fetchMagnetURLAndAdd(to: clients[indexPath.row])
    }
}

extension MagnetPopupVC : SYPopoverContentViewDelegate {
    func popoverControllerShouldDismiss(onBackgroundTap popoverController: SYPopoverController!) -> Bool {
        return canClose
    }
    
    func popoverControllerBackgroundColor(_ popoverController: SYPopoverController!) -> UIColor! {
        return nil
    }
}

