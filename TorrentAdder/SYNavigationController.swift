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

        navigationBar.setBackgroundImage(UIImage.sy_image(with: .lightBlue), for: .default)
        navigationBar.setBackgroundImage(UIImage.sy_image(with: .lightBlue), for: .compact)
        navigationBar.tintColor = .white
        navigationBar.barStyle = .blackOpaque
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
}
