//
//  SYNavigationController.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class SYNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = .lightBlue()
        navigationBar.tintColor = .white
        navigationBar.barStyle = .blackOpaque
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
}
