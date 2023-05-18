//
//  SuggestionsVC.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 21/07/2020.
//  Copyright © 2020 Syan. All rights reserved.
//

import UIKit

class SuggestionsVC: ViewController {
    
    // MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerCell(SuggestionCell.self)
        tableView.tableFooterView = UIView()
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: .new, context: nil)
        reloadContent()
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize))
    }
    
    // MARK: Properties
    var input: String = "" {
        didSet { reloadContent() }
    }
    var selectedSuggestionBlock: ((String) -> ())?

    private var filteredSuggestions = [String]()
    
    // MARK: Views
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Content
    private func reloadContent() {
        guard isViewLoaded else { return }

        filteredSuggestions = []
        if input.isNotEmpty {
            // don't show anything until something has been typed
            filteredSuggestions = Preferences.shared.prevSearches.filter { $0.lowercased().contains(input.lowercased()) }
        }
        tableView.reloadData()
        updatePopover()
    }
    
    // MARK: Layout
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? UITableView) == tableView && keyPath == #keyPath(UITableView.contentSize) {
            updatePopover()
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    private func updatePopover() {
        guard let window = view.window else { return }
        preferredContentSize.width  = min(320, max(500, window.bounds.width - 40))
        preferredContentSize.height = min(500, max(300, tableView.contentSize.height))
        popoverPresentationController?.containerView?.alpha = filteredSuggestions.isEmpty ? 0.05 : 1 // don't set under 0.05 or touch won't hit it and it will cause navigation issues
    }
    
    // MARK: Presentation
    static func present(under view: UIView, in viewController: UIViewController) -> SuggestionsVC {
        let vc = SuggestionsVC()
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.permittedArrowDirections = [.up]
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.sourceRect = view.bounds
        vc.popoverPresentationController?.passthroughViews = [view]
        
        viewController.present(vc, animated: true, completion: nil)
        return vc
    }
    
    static func shouldPresentPopover(for input: String?) -> Bool {
        guard let input = input, input.isNotEmpty else { return false }
        return Preferences.shared.prevSearches.filter { $0.lowercased().contains(input.lowercased()) }.isNotEmpty
    }
}

extension SuggestionsVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(SuggestionCell.self, for: indexPath)
        cell.suggestion = filteredSuggestions[indexPath.row]
        return cell
    }
}

extension SuggestionsVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSuggestionBlock?(filteredSuggestions[indexPath.row])
    }
}

extension SuggestionsVC : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
