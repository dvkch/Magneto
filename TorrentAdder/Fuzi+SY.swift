//
//  Fuzi+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Fuzi

extension Fuzi.XMLElement {
    var textNode: Fuzi.XMLNode? {
        return childNodes(ofTypes: [.Text]).first
    }
    
    var text: String? {
        return textNode?.stringValue
    }
}
