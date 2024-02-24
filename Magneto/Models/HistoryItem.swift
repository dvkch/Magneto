//
//  HistoryItem.swift
//  Magneto
//
//  Created by syan on 24/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation

struct HistoryItem: Codable {
    let date: Date
    let search: String
    
    init(search: String) {
        self.date = Date()
        self.search = search.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case search = "search"
    }
    
    func matches(_ query: String) -> Bool {
        return search.localizedStandardContains(query)
    }
}

extension HistoryItem: Identifiable {
    var id: String {
        return search.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
    }
}
