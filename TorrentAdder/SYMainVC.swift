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

class SYMainVC: UIViewController {

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidOpenURLNotification(_:)), name: .didOpenURL, object: nil)
        
        timerRefreshComputers = Timer(timeInterval: 5, target: self, selector: #selector(self.refreshComputersTimerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timerRefreshComputers!, forMode: .common)

        titleLabel.addGlow(color: .lightGray, size: 4)

        searchField.backgroundColor = UIColor(white: 1, alpha: 0.3)
        searchField.activityIndicatorView.color = .black
        searchField.textField.keyboardType = .default
        searchField.textField.placeholder = "Search"
        searchField.textField.rightViewMode = .always
        searchField.textField.clearButtonMode = .always
        
        tableView.registerCell(name: SYComputersCell.className)
        tableView.registerCell(name: SYComputerCell.className)
        tableView.registerCell(name: SYResultCell.className)
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        
        constraintBlueHeaderHeightOriginalValue = constraintBlueHeaderHeight.constant
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        computers = SYDatabase.shared.computers()
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didOpenURL, object: nil)
        timerRefreshComputers?.invalidate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Properties
    private var timerRefreshComputers: Timer?
    private var computers: [SYComputerModel] = []
    private var searchResults: [SYResultModel] = []
    private var searchQuery: String = ""
    private var constraintBlueHeaderHeightOriginalValue: CGFloat = 0
    private var isVisible: Bool = false
    private var showingSearch: Bool { return !searchQuery.isEmpty }
    
    // MARK: Views
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var searchField: SYSearchField!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var constraintBlueHeaderHeight: NSLayoutConstraint!
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
    
    @objc private func refreshComputersTimerTick() {
        if view.window == nil { return }
        computers.forEach {
            SYClientStatusManager.shared.startStatusUpdate(for: $0)
        }
    }
}

// MARK: Actions
extension SYMainVC {
    @IBAction private func helpButtonTap() {
        let alert = UIAlertController(
            title: "Help",
            message: "To add a torrent you need to open this app with a magnet. Go to Safari, open a page with a magnet link in it, click the magnet to open this app, and then select a computer to start downloading the torrent.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func updateSearch(_ text: String) {
        searchQuery = text
        searchField.titleText = text
        
        guard !searchQuery.isEmpty else {
            searchResults = []
            searchField.showLoadingIndicator(false)
            tableView.reloadData()
            return
        }
        
        searchField.showLoadingIndicator(true)
        SYWebAPI.shared.look(for: text) { [weak self] items, error in
            guard let self = self else { return }
            guard self.searchQuery == text else { return }
            
            self.searchField.showLoadingIndicator(false)
            self.searchResults = items ?? []
            self.tableView.reloadData()
            self.tableView.contentOffset.y = 0
            
            if let error = error {
                let alert = UIAlertController(title: "Cannot load results", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func openTorrentPopup(with magnetURL: URL?, or result: SYResultModel?, sourceApp: SYSourceApp?) {
        guard !computers.isEmpty else {
            let alert = UIAlertController(
                title: "Cannot add torent",
                message: "No computer saved in your settings, please add one before trying to download this item",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        SYAddMagnetPopupVC.show(in: self, magnet: magnetURL, result: result, sourceApp: sourceApp)
    }
    
    fileprivate func removeComputer(_ computer: SYComputerModel, at indexPath: IndexPath) {
        SYDatabase.shared.removeComputer(computer)
        
        if let index = self.computers.index(of: computer) {
            self.computers.remove(at: index)
        }
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
        tableView.endUpdates()
    }
    
    fileprivate func shareResult(_ result: SYResultModel, from cell: UITableViewCell?) {
        let vc = UIActivityViewController(activityItems: [result.fullURL], applicationActivities: nil)
        vc.popoverPresentationController?.sourceRect = cell?.frame ?? .zero
        vc.popoverPresentationController?.sourceView = self.view
        
        // TODO: use better sourceRect (centered ?) and arrowDirection
        self.present(vc, animated: true, completion: nil)
        self.tableView.setEditing(false, animated: true)
    }
}

extension SYMainVC : SYSearchFieldDelegate {
    func searchFieldDidReturn(_ searchField: SYSearchField!, withText text: String!) {
        updateSearch(text)
    }
}

extension SYMainVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        constraintBlueHeaderHeight.constant = constraintBlueHeaderHeightOriginalValue - min(0, scrollView.contentOffset.y)
    }
}

extension SYMainVC : UITableViewDataSource {
    enum TableSection : Int {
        case buttons, computers, results
        static let all: [TableSection] = [.buttons, .computers, .results]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.all.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = TableSection(rawValue: section) else { return 0 }
        switch tableSection {
        case .buttons:      return showingSearch ? 0 : 1
        case .computers:    return showingSearch ? 0 : computers.count
        case .results:      return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tableSection = TableSection(rawValue: section) else { return nil }
        switch tableSection {
        case .buttons:      return showingSearch ? nil : "Available computers"
        case .computers:    return nil
        case .results:
            if !showingSearch { return nil }
            return searchResults.isEmpty ? "No results" : "Results"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch tableSection {
        case .buttons:
            let cell = tableView.dequeueReusableCell(withIdentifier: SYComputersCell.className, for: indexPath) as! SYComputersCell
            cell.computersCount = computers.count
            cell.addButtonTapBlock = { [weak self] in
                let vc = SYListComputersVC()
                let nc = SYNavigationController(rootViewController: vc)
                self?.present(nc, animated: true, completion: nil)
            }
            return cell
        case .computers:
            let cell = tableView.dequeueReusableCell(withIdentifier: SYComputerCell.className, for: indexPath) as! SYComputerCell
            cell.computer = computers[indexPath.row]
            cell.isAvailableComputersList = false
            return cell
        case .results:
            let cell = tableView.dequeueReusableCell(withIdentifier: SYResultCell.className, for: indexPath) as! SYResultCell
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
        case .computers: return 60
        case .results: return 80
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return 0 }
        switch tableSection {
        case .buttons: return 60
        case .computers: return 60
        case .results: return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tableSection = TableSection(rawValue: indexPath.section) else { return }
        switch tableSection {
        case .buttons:
            let vc = SYListComputersVC()
            let nc = SYNavigationController(rootViewController: vc)
            present(nc, animated: true, completion: nil)

        case .computers:
            guard let url = computers[indexPath.row].webURL() else { return }
            let vc = SFSafariViewController(url: url)
            if #available(iOS 10, *) {
                vc.preferredBarTintColor = .lightBlue()
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
            
        case .computers:
            let computer = computers[indexPath.row]
            let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (_, _) in
                let vc = SYEditComputerVC()
                vc.computer = computer
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (_, indexPath) in
                self?.removeComputer(computer, at: indexPath)
            }
            return [editAction, deleteAction]
            
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
