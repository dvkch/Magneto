//
//  SYComputerFormCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class SYComputerFormCell: UITableViewCell {

    // MARK: Properties
    var formField: SYComputerModelField = SYComputerModelField_Host {
        didSet {
            updateContent()
        }
    }
    var computer: SYComputerModel? {
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
        computer?.setValue(textField.text, for: formField)
    }
    
    // MARK: Content
    private func updateContent() {
        guard let computer = computer else { return }
        
        iconView.image = computer.image(for: formField)?.sy_imageMasked(with: .lightBlue())
        textField.keyboardType = computer.keyboardType(for: formField)
        
        if let options = computer.options(forEnumField: formField) {
            textField.isHidden = true
            segmentedControl.isHidden = false
            segmentedControl.removeAllSegments()
            options.forEach { (option) in
                segmentedControl.insertSegment(withTitle: option, at: segmentedControl.numberOfSegments, animated: false)
            }
            segmentedControl.selectedSegmentIndex = (computer.value(for: formField) as? Int) ?? 0
        }
        else {
            textField.isHidden = false
            segmentedControl.isHidden = true
            textField.placeholder = computer.name(for: formField)
            textField.text = computer.value(for: formField) as? String
        }
    }
}

extension SYComputerFormCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        computer?.setValue(textField.text, for: formField)
        textField.resignFirstResponder()
        return false
    }
}
