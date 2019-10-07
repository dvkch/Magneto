//
//  ClientFormCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class ClientFormCell: UITableViewCell {
    
    // MARK: Init
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.textColor = .text
        segmentedControl.tintColor = .accent
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
        
        iconView.image = formField.image?.masking(with: .accent)
        textField.keyboardType = formField.keyboardType
        if #available(iOS 11.0, *) {
            textField.textContentType = formField.textContentType
        }

        if let options = formField.options, !options.isEmpty {
            textField.isHidden = true
            segmentedControl.isHidden = false
            segmentedControl.removeAllSegments()
            options.keys.sorted().forEach { (index) in
                segmentedControl.insertSegment(withTitle: options[index], at: index, animated: false)
            }
            segmentedControl.selectedSegmentIndex = client.intValue(for: formField) ?? 0
        }
        else {
            textField.isHidden = false
            segmentedControl.isHidden = true
            textField.placeholder = formField.name
            textField.text = client.stringValue(for: formField)
        }
    }
    
    // MARK: Style
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContent()
    }
}

extension ClientFormCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        client?.setValue(textField.text ?? "", for: formField)
        textField.resignFirstResponder()
        return false
    }
}
