//
//  Client+UI.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension Client {
    enum FormError {
        case missing, invalid, missingIfHas(otherField: FormField)
        
        func message(for field: FormField) -> String {
            switch self {
            case .missing:                      return "error.form.missing %@".localized(field.name)
            case .invalid:                      return "error.form.missingIfHas %@ %@".localized(field.name)
            case .missingIfHas(let otherField): return "error.form.invalid %@".localized(field.name, otherField.name)
            }
        }
    }

    var formErrors: [FormField: FormError] {
        var errors = [FormField: FormError]()
        if name.isEmpty {
            errors[.name] = .missing
        }
        if host.isEmpty {
            errors[.host] = .missing
        }
        if (password ?? "").isNotEmpty && (username ?? "").isEmpty {
            errors[.username] = .missingIfHas(otherField: .password)
        }
        return errors
    }
}

extension Client {
    enum FormField : CaseIterable {
        case name, host, port, software, username, password
        
        var name: String {
            switch self {
            case .name:     return "client.name".localized
            case .host:     return "client.host".localized
            case .port:     return "client.port".localized
            case .software: return "client.software".localized
            case .username: return "client.username".localized
            case .password: return "client.password".localized
            }
        }
        
        var placeholder: String {
            switch self {
            case .name:     return "client.name.placeholder".localized
            case .host:     return "client.host.placeholder".localized
            case .port:     return "client.port.placeholder".localized
            case .software: return "client.software.placeholder".localized
            case .username: return "client.username.placeholder".localized
            case .password: return "client.password.placeholder".localized
            }
        }
        
        var image: UIImage? {
            switch self {
            case .name:     return .icon(.bookmark)
            case .host:     return .icon(.network)
            case .port:     return .icon(.number)
            case .software: return .icon(.app)
            case .username: return .icon(.user)
            case .password: return .icon(.secret)
            }
        }
        
        var options: [Int: String]? {
            switch self {
            case .software: return [Software.transmission.rawValue: "Transmission"]
            default:        return nil
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .name:     return .default
            case .host:     return .URL
            case .port:     return .numberPad
            case .software: return .default
            case .username: return .default
            case .password: return .default
            }
        }
        
        var textContentType: UITextContentType? {
            switch self {
            case .name:     return nil
            case .host:     return .URL
            case .port:     return nil
            case .software: return nil
            case .username: return .username
            case .password: return .password
            }
        }
    }
}

extension Client {
    func stringValue(for field: FormField) -> String? {
        switch field {
        case .name:     return name
        case .host:     return host
        case .port:     return port.map(String.init)
        case .software: return nil
        case .username: return username
        case .password: return password
        }
    }
    
    func intValue(for field: FormField) -> Int? {
        switch field {
        case .name:     return nil
        case .host:     return nil
        case .port:     return port
        case .software: return software.rawValue
        case .username: return nil
        case .password: return nil
        }
    }
    
    func setValue(_ value: Any, for field: FormField) {
        switch field {
        case .name:     name = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? name
        case .host:     host = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? host
        case .port:     port = (value as? Int) ?? port
        case .software: software = Software(rawValue: (value as? Int) ?? software.rawValue) ?? software
        case .username: username = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? username
        case .password: password = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? password
        }
    }
}
