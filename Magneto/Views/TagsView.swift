//
//  TagsView.swift
//  Magneto
//
//  Created by syan on 14/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import UIKit

protocol TagsViewDelegate: NSObjectProtocol {
    func tagsView(_ tagsView: TagsView, didTapItem item: any Taggable, sender: UIView)
}

protocol Taggable {
    var tag: String { get }
}

class TagsView: UIView {
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
    }
    
    // MARK: Properties
    weak var delegate: TagsViewDelegate?
    var tags: [any Taggable] = [] {
        didSet {
            updateContent()
        }
    }
    private var tagViews = [UIButton]()
    
    // MARK: Actions
    @objc private func tagViewPressed(sender: UIButton) {
        delegate?.tagsView(self, didTapItem: tags[sender.tag], sender: sender)
    }
    
    // MARK: Content
    private func updateContent() {
        tagViews.forEach { $0.removeFromSuperview() }
        tagViews.removeAll()
        
        for (i, tag) in tags.enumerated() {
            let view = UIButton()
            
            // content
            view.tag = i
            view.setTitle(tag.tag, for: .normal)
            view.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
            view.addTarget(self, action: #selector(self.tagViewPressed(sender:)), for: .primaryActionTriggered)

            // borders
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor.altText.cgColor
            view.layer.borderWidth = 1
            view.layer.masksToBounds = true

            // colors
            view.backgroundColor = .clear
            view.setTitleColor(.altText, for: .normal)
            view.setTitleColor(.backgroundAlt, for: .highlighted)
            view.setBackgroundColor(.altText, for: .highlighted)

            // layout
            view.contentEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
            view.setContentHuggingPriority(.required, for: .horizontal)
            view.setContentHuggingPriority(.required, for: .vertical)
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            view.setContentCompressionResistancePriority(.required, for: .vertical)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]

            addSubview(view)
            tagViews.append(view)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let first = tagViews.first else { return }

        let spacing: CGFloat = 8
        let height = first.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).height

        var previousX: CGFloat = 0
        var previousY: CGFloat = 0

        for tagView in tagViews {
            let width = tagView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
            if previousX + width > bounds.width {
                previousX = 0
                previousY += height + spacing
            }
            tagView.frame = .init(x: previousX, y: previousY, width: width, height: height)
            previousX += spacing + width
        }

        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: tagViews.last?.frame.maxY ?? 0)
    }
}
