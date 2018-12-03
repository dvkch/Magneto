//
//  SYComputerFormCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class SYComputerFormCell: UITableViewCell {
    
    // MARK: Init
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.tintColor = .lightBlue
    }

    // MARK: Properties
    var formField: SYClient.FormField = .host {
        didSet {
            updateContent()
        }
    }
    var computer: SYClient? {
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
        computer?.setValue(segmentedControl.selectedSegmentIndex, for: formField)
    }
    
    @IBAction private func textFieldEditingChanged() {
        computer?.setValue(textField.text ?? "", for: formField)
    }
    
    // MARK: Content
    private func updateContent() {
        guard let computer = computer else { return }
        
        iconView.image = formField.image?.sy_imageMasked(with: .lightBlue)
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
            segmentedControl.selectedSegmentIndex = computer.intValue(for: formField) ?? 0
        }
        else {
            textField.isHidden = false
            segmentedControl.isHidden = true
            textField.placeholder = formField.name
            textField.text = computer.stringValue(for: formField)
        }
    }
}

extension SYComputerFormCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        computer?.setValue(textField.text ?? "", for: formField)
        textField.resignFirstResponder()
        return false
    }
}
