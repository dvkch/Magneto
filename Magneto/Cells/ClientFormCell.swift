//
//  ClientFormCell.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

class ClientFormCell: UITableViewCell {
    
    // MARK: Init
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.textColor = .normalText
        textField.backgroundColor = .cellBackgroundAlt
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    // MARK: Properties
    var formField: Client.FormField = .host {
        didSet {
            updateContent()
        }
    }
    var client: Client? {
        didSet {
            updateContent()
        }
    }
    
    // MARK: Views
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var textField: UITextField!

    // MARK: Actions
    @IBAction private func textFieldEditingChanged() {
        client?.setValue(textField.text ?? "", for: formField)
    }
    
    // MARK: Content
    private func updateContent() {
        guard let client = client else { return }
        
        iconView.image = formField.image?.withTintColor(.tint)
        nameLabel.text = formField.name
        textField.keyboardType = formField.keyboardType
        textField.textContentType = formField.textContentType

        textField.placeholder = formField.placeholder
        textField.text = client.stringValue(for: formField)
    }

    // MARK: Actions
    @objc private func textFieldChanged() {
        client?.setValue(textField.text ?? "", for: formField)
    }
    
    // MARK: Style
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContent()
    }
}

extension ClientFormCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
