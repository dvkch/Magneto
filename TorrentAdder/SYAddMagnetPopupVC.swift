//
//  SYAddMagnetPopupVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYPopoverController

class SYAddMagnetPopupVC: UIViewController {

    // MARK: Presentation
    static func show(in viewController: UIViewController, magnet: URL?, result: SYSearchResult?, sourceApp: SYSourceApp?) {
        let popupVC = SYAddMagnetPopupVC()
        popupVC.sourceApp = sourceApp
        popupVC.result = result
        popupVC.magnetURL = magnet
        viewController.sy_presentPopover(popupVC, animated: true, completion: nil)
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        
        preferredContentSize = CGSize(width: 300, height: 250)
        
        tableView.registerCell(name: SYComputerCell.className)
        tableView.tableFooterView = UIView()
        
        cancelButton.setTitle("Cancel", for: .normal)
        closeButton.setTitle("Close", for: .normal)
        backToAppButton.setTitle("Go back to app", for: .normal)
        
        for button in [cancelButton!, closeButton!, backToAppButton!] {
            button.backgroundColor = .clear
            button.setTitleColor(.darkText, for: .normal)
            button.setTitleColor(.gray, for: .highlighted)
            
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = UIColor(white: 0.9, alpha: 1)
            button.addSubview(separator)
            
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            separator.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
            separator.leftAnchor.constraint(equalTo: button.leftAnchor).isActive = true
            separator.rightAnchor.constraint(equalTo: button.rightAnchor).isActive = true
        }
        
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        spinner.color = .gray
        
        computers = SYDatabase.shared.computers()
        updateForMode(.computers, animated: false)
    }
    
    // MARK: Properties
    private var sourceApp: SYSourceApp?
    private var magnetURL: URL?
    private var result: SYSearchResult?
    private var computers = [SYComputerModel]()
    private var canClose: Bool = false

    // MARK: Views
    @IBOutlet private var statusContainerView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var spinner: UIActivityIndicatorView!
    @IBOutlet private var backToAppButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    
    // MARK: Actions
    @IBAction private func backToAppButtonTap() {
        AppDelegate.obtain.openApp(sourceApp)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func closeButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: API
    private func fetchMagnetURLAndAdd(to computer: SYComputerModel) {
        updateForMode(.loading, animated: true)
        
        if let magnetURL = (magnetURL ?? result?.magnetURL) {
            addMagnetToComputer(magnetURL: magnetURL, computer: computer)
            return
        }
        
        guard let result = result else { return }
        
        _ = SYWebAPI.shared.getMagnet(for: result)
            .onSuccess { [weak self] (magnetURL) in
                self?.addMagnetToComputer(magnetURL: magnetURL, computer: computer)
            }
            .onFailure { [weak self] (error) in
                self?.updateForMode(.failure(error.localizedDescription), animated: true)
            }
    }
    
    private func addMagnetToComputer(magnetURL: URL, computer: SYComputerModel) {
        updateForMode(.loading, animated: true)
        
        SYClientAPI.shared()?.addMagnet(magnetURL, toComputer: computer, completion: { (message, error) in
            if let error = error {
                let errorMessage = error.isOfflineError ? "Computer unavailble" : error.localizedDescription
                self.updateForMode(.failure(errorMessage), animated: true)
                return
            }
            
            var successMessage = "Success!"
            if let message = message {
                successMessage = successMessage.appendingFormat("\n\nMessage from %@: %@", computer.name, message)
            }
            self.updateForMode(.success(successMessage), animated: true)
            
        })
    }
    
    // MARK: Content
    enum Mode {
        case computers, loading, success(_ message: String), failure(_ error: String)
    }
    
    private func updateForMode(_ mode: Mode, animated: Bool) {
        if animated {
            UIView.transition(with: view, duration: 0.3, options: [.transitionCrossDissolve, .layoutSubviews], animations: {
                self.updateForMode(mode, animated: false)
            }, completion: nil)
            return
        }
        
        switch mode {
        case .computers:
            canClose = true
            tableView.alpha = 1
            statusContainerView.alpha = 0
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: false)
            }
            
            backToAppButton.sy_isHidden = true
            cancelButton.sy_isHidden = false
            closeButton.sy_isHidden = true

        case .loading:
            canClose = false
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            statusLabel.text = "Loading..."
            spinner.sy_isHidden = false
            spinner.startAnimating()
            
            backToAppButton.sy_isHidden = true
            cancelButton.sy_isHidden = true
            closeButton.sy_isHidden = true

        case .success(let message):
            canClose = true
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            spinner.stopAnimating()
            spinner.sy_isHidden = true
            statusLabel.text = message
            
            backToAppButton.sy_isHidden = sourceApp == nil
            cancelButton.sy_isHidden = true
            closeButton.sy_isHidden = false

        case .failure(let error):
            canClose = false
            tableView.alpha = 0
            statusContainerView.alpha = 1
            
            spinner.stopAnimating()
            spinner.sy_isHidden = true
            statusLabel.text = error
            
            backToAppButton.sy_isHidden = true
            cancelButton.sy_isHidden = true
            closeButton.sy_isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.updateForMode(.computers, animated: true)
            }
        }
    }
}

extension SYAddMagnetPopupVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return computers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SYComputerCell.className, for: indexPath) as! SYComputerCell
        cell.computer = computers[indexPath.row]
        cell.isAvailableComputersList = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return result?.name ?? magnetURL?.magnetName?.capitalized
    }
}

extension SYAddMagnetPopupVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        fetchMagnetURLAndAdd(to: computers[indexPath.row])
    }
}

extension SYAddMagnetPopupVC : SYPopoverContentViewDelegate {
    func popoverControllerShouldDismiss(onBackgroundTap popoverController: SYPopoverController!) -> Bool {
        return canClose
    }
    
    func popoverControllerBackgroundColor(_ popoverController: SYPopoverController!) -> UIColor! {
        return UIColor(white: 0.7, alpha: 0.7)
    }
}

