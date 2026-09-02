//
//  URL+SY.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan.
//

import UIKit

extension URL {
    var magnetName: String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let nameQuery = components.queryItems?.first(where: { $0.name == "dn" }) else { return nil }
        return nameQuery.value
    }
}
