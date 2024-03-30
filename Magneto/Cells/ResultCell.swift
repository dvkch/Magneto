//
//  ResultCell.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

protocol ResultCellDelegate: NSObjectProtocol {
    func resultCell(_ resultCell: ResultCell, requiresReloadFor result: any SearchResult)
    func resultCell(_ resultCell: ResultCell, tapped variant: SearchResultVariant, sender: UIView)
    func resultCell(_ resultCell: ResultCell, encounteredError error: AppError)
}

class ResultCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .cellBackground
        
        variantsView.tagViewClass = Magneto.TagView.self
        variantsView.delegate = self
    }

    // MARK: Properties
    weak var delegate: ResultCellDelegate?
    var result: (any SearchResult)? {
        didSet {
            updateContent()
            updateVariants(afterAPICall: false)
        }
    }
    
    // MARK: Views
    @IBOutlet private var label: UILabel!
    @IBOutlet private var loader: UIActivityIndicatorView!
    @IBOutlet private var variantsView: TagsView!

    // MARK: Actions
    func runMainAction() {
        guard let result else { return }
        if let variant = result.uniqueVariant {
            delegate?.resultCell(self, tapped: variant, sender: self)
        }
        else if result.variants == nil {
            loadVariants()
        }
    }
    
    // MARK: Debounce cell height refresh
    private var refreshHeightTimer = Timer()
    private func refreshHeight() {
        refreshHeightTimer.invalidate()
        refreshHeightTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(refreshHeightNow), userInfo: nil, repeats: false)
        RunLoop.main.add(refreshHeightTimer, forMode: .common)
    }

    @objc private func refreshHeightNow() {
        guard let result else { return }
        delegate?.resultCell(self, requiresReloadFor: result)
    }
    
    // MARK: Content
    private func updateContent() {
        guard let result else {
            label.text = nil
            return
        }
        
        // first line
        let title = NSMutableAttributedString()
        title.append(result.name, font: .preferredFont(forTextStyle: .body), color: .normalText)
        if result.verified {
            title.append(" ✔️", font: .preferredFont(forTextStyle: .caption2), color: nil)
        }

        // second line
        var details = [NSAttributedString]()

        if let added = result.added {
            var dateFont = UIFont.preferredFont(forTextStyle: .footnote)
            if result.recentness == .new {
                dateFont = UIFont.systemFont(ofSize: dateFont.pointSize, weight: .bold)
            }
            else if result.recentness == .recent {
                dateFont = UIFont.systemFont(ofSize: dateFont.pointSize, weight: .semibold)
            }
            details.append(.init(string: added, font: dateFont, color: .altText))
        }

        if let variant = result.uniqueVariant {
            if let size = variant.size {
                details.append(.init(string: size, font: .preferredFont(forTextStyle: .footnote), color: .altText))
            }
            if let seeders = variant.seeders, let leechers = variant.leechers {
                let seeding = NSMutableAttributedString()
                seeding.append(String(seeders), font: .preferredFont(forTextStyle: .footnote), color: .seeder)
                seeding.append("/", font: .preferredFont(forTextStyle: .footnote), color: .gray)
                seeding.append(String(leechers), font: .preferredFont(forTextStyle: .footnote), color: .leechers)
                details.append(seeding)
            }
        }
        
        // update label
        let detailsString = details.concat(separator: .init(string: ", ", font: nil, color: .altText))
        let separator = details.isEmpty ? "" : "\n"
        label.attributedText = [title, detailsString].concat(separator: separator)
    }
    
    private func loadVariants() {
        guard let result else { 
            loader.stopAnimating()
            return
        }

        loader.startAnimating()
        
        let startTime = Date()

        result.loadVariants()
            .onComplete { [weak self] _ in
                guard let self else { return }
                loader.stopAnimating()
            }
            .onFailure { [weak self] in
                guard let self else { return }
                delegate?.resultCell(self, encounteredError: $0)
            }
            .onSuccess { [weak self] _ in
                guard let self else { return }
                updateVariants(afterAPICall:  true)
                if result.variants?.unique != nil, Date().timeIntervalSince(startTime) < 2 {
                    runMainAction()
                }
            }
    }
    
    private func updateVariants(afterAPICall: Bool) {
        guard let variants = result?.variants, variants.count > 1 else {
            variantsView.sy_isHidden = true
            if afterAPICall {
                refreshHeight()
            }
            return
        }
        
        variantsView.sy_isHidden = false
        variantsView.tags = variants.map { $0.tag }

        if afterAPICall {
            refreshHeight()
        }
    }
}

extension ResultCell: TagsViewDelegate {
    func tagsView(_ tagsView: TagsView, didTapItem item: Tag, sender: UIView) {
        delegate?.resultCell(self, tapped: item.object as! SearchResultVariant, sender: sender)
    }
}
