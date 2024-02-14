//
//  UISearchController+SYKit.swift
//  SYKit
//
//  Created by syan on 24/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

public extension UISearchController {
    @available(iOS 16.0, tvOS 14.0, *)
    private var suggestionsCollectionView: UICollectionView? {
        // _UISearchSuggestionsListCollectionViewCell
        let cellClass = NSClassFromString("_UISearchSuggestionsLi" + "lleCweiVnoitcelloCts".reversed()) as? UICollectionViewListCell.Type
        guard let cellClass else {
            print("suggestion cell class type doesn't exist, aborting")
            return nil
        }

        let suggestionCell = view.subviews(ofKind: cellClass, recursive: true).first
        return suggestionCell?.superview as? UICollectionView
    }
    
    @available(iOS 16.0, tvOS 14.0, *)
    var selectedSuggestion: UISearchSuggestion? {
        guard let suggestionsCollectionView else { return nil }
        guard let selectedCell = suggestionsCollectionView.visibleCells.first(where: { $0.isFocused }) else { return nil }
        guard let selectedIndex = suggestionsCollectionView.indexPath(for: selectedCell) else { return nil }
        return searchSuggestions?[selectedIndex.row]
    }
}
