//
//  ApiError.swift
//  Magneto
//
//  Created by syan on 15/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation

struct ApiError: Decodable {
    let message: String
    let details: String?
}
