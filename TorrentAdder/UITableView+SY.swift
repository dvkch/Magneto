//
//  UITableView+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension UITableView {

    func registerCell(name: String) {
        register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
    
    func registerCell(class cellClass: AnyClass) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    func registerHeaderClass(_ headerclass: AnyClass) {
        register(headerclass, forHeaderFooterViewReuseIdentifier: String(describing: headerclass))
    }
    
    func dequeueCell(style: UITableViewCell.CellStyle) -> UITableViewCell {
        let identifier = "cell" + String(style.rawValue)
        return dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: style, reuseIdentifier: identifier)
    }
    
    func dequeueCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.className, for: indexPath) as! T
    }
}
