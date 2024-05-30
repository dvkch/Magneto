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
            case .missing:                      return L10n.Error.Form.missing(field.name)
            case .invalid:                      return L10n.Error.Form.invalid(field.name)
            case .missingIfHas(let otherField): return L10n.Error.Form.missingIfHas(field.name, otherField.name)
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
        case name, host, port, username, password
        
        var name: String {
            switch self {
            case .name:     return L10n.Client.name
            case .host:     return L10n.Client.host
            case .port:     return L10n.Client.port
            case .username: return L10n.Client.username
            case .password: return L10n.Client.password
            }
        }
        
        var placeholder: String {
            switch self {
            case .name:     return L10n.Client.Name.placeholder
            case .host:     return L10n.Client.Host.placeholder
            case .port:     return L10n.Client.Port.placeholder
            case .username: return L10n.Client.Username.placeholder
            case .password: return L10n.Client.Password.placeholder
            }
        }
        
        var image: UIImage? {
            switch self {
            case .name:     return .icon(.bookmark)
            case .host:     return .icon(.network)
            case .port:     return .icon(.number)
            case .username: return .icon(.user)
            case .password: return .icon(.secret)
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .name:     return .default
            case .host:     return .URL
            case .port:     return .numberPad
            case .username: return .default
            case .password: return .default
            }
        }
        
        var textContentType: UITextContentType? {
            switch self {
            case .name:     return nil
            case .host:     return .URL
            case .port:     return nil
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
        case .username: return username
        case .password: return password
        }
    }
    
    func intValue(for field: FormField) -> Int? {
        switch field {
        case .name:     return nil
        case .host:     return nil
        case .port:     return port
        case .username: return nil
        case .password: return nil
        }
    }
    
    func setValue(_ value: Any, for field: FormField) {
        switch field {
        case .name:     name = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? name
        case .host:     host = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? host
        case .port:     port = (value as? Int) ?? port
        case .username: username = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? username
        case .password: password = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? password
        }
    }
}
