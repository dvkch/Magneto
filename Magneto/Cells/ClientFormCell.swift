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
        segmentedControl.tintColor = .tint
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
    @IBOutlet private var segmentedControl: UISegmentedControl!

    // MARK: Actions
    @IBAction private func segmentedControlChanged() {
        client?.setValue(segmentedControl.selectedSegmentIndex, for: formField)
    }
    
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

        if let options = formField.options, !options.isEmpty {
            textField.sy_isHidden = true
            segmentedControl.sy_isHidden = false
            segmentedControl.removeAllSegments()
            options.keys.sorted().forEach { (index) in
                segmentedControl.insertSegment(withTitle: options[index], at: index, animated: false)
            }
            segmentedControl.selectedSegmentIndex = client.intValue(for: formField) ?? 0
            segmentedControl.setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .body)], for: .normal)
        }
        else {
            textField.sy_isHidden = false
            segmentedControl.sy_isHidden = true
            textField.placeholder = formField.placeholder
            textField.text = client.stringValue(for: formField)
        }
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
