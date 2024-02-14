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
    func tagsViewHeightChanged(_ tagsView: TagsView)
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

        collectionView.backgroundColor = .clear
        collectionView.registerCell(TagCell.self, xib: false)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionLayout.scrollDirection = .vertical
        collectionLayout.minimumInteritemSpacing = 8
        collectionLayout.minimumLineSpacing = 8
        collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        heightConstraint = collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        NSLayoutConstraint.activate([heightConstraint])

        collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: nil)
    }
    
    deinit {
        collectionView.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: nil)
    }

    // MARK: Properties
    weak var delegate: TagsViewDelegate?
    var tags: [any Taggable] = [] {
        didSet {
            updateContent()
        }
    }
    
    // MARK: Views
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: TagsLayout())
    private var collectionLayout: UICollectionViewFlowLayout { collectionView.collectionViewLayout as! TagsLayout }
    private var heightConstraint: NSLayoutConstraint!
    
    // MARK: Content
    private func updateContent() {
        collectionView.reloadData()
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionView.contentSize
    }
    
    // MARK: Layout
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? UIView) == collectionView, keyPath == #keyPath(UICollectionView.contentSize) {
            invalidateIntrinsicContentSize()
            delegate?.tagsViewHeightChanged(self)
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}

extension TagsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(TagCell.self, for: indexPath)
        cell.text = tags[indexPath.row].tag
        return cell
    }
}

extension TagsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.tagsView(self, didTapItem: tags[indexPath.row], sender: collectionView.cellForItem(at: indexPath)!)
    }
}
