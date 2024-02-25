//
//  IdentifiableResult.swift
//  Magneto
//
//  Created by syan on 24/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation

struct IdentifiableResult: Identifiable {
    let result: any SearchResult

    var id: UUID {
        return result.id
    }
}

extension IdentifiableResult: Hashable, Equatable {
    static func == (lhs: IdentifiableResult, rhs: IdentifiableResult) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
