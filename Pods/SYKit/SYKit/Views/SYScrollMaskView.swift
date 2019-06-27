//
//  SYScrollMaskView.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

// MARK: test

/**
 * @class SYScrollMaskView
 *
 * Container for UIScrollView and subclasses, used to mask the top and
 * bottom (or left and right) of a scrollview. This creates an effect
 * that shows the user there is something so scroll to.
 *
 * The only way to achieve that is to add the scrollView to this view, which
 * is itself masked to achieve the desired effect, since scrollViews can't be
 * directly masked (shows weird glitches, tableView cells are dropped, gradient
 * moves when we scroll etc)
 *
 * You should position this view as you would have your scrollView, set the
 * scrollView property (this will add the scrollView to this container) and
 * set the desired mask orientation and size.
 *
 */
@objcMembers
public class SYScrollMaskView: UIView {
    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = nil
        
        gradientLayer1.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer1.startPoint = .zero
        gradientLayer1.locations = [0, 1]
        gradientLayer1.type = .axial
        layer.addSublayer(gradientLayer1)
        
        gradientLayer2.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer2.endPoint = .zero
        gradientLayer2.locations = [0, 1]
        gradientLayer2.type = .axial
        layer.addSublayer(gradientLayer2)
        
        setNeedsLayout()
    }
    
    // MARK: Properties
    @objc(SYScrollMask)
    public enum MaskType: Int {
        case none, vertical, horizontal
    }
    
    public weak var scrollView: UIScrollView? {
        didSet {
            oldValue?.mask = nil
            scrollView?.mask = self
        }
    }
    public var scrollMask: MaskType = .vertical {
        didSet { setNeedsLayout() }
    }
    public var scrollMaskSize: CGFloat = 16 {
        didSet { setNeedsLayout() }
    }
    
    // MARK: Private properties
    private let gradientLayer1 = CAGradientLayer()
    private let gradientLayer2 = CAGradientLayer()

    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        switch scrollMask {
        case .none:
            gradientLayer1.isHidden = true
            gradientLayer2.isHidden = true
            
        case .vertical:
            gradientLayer1.isHidden = false
            gradientLayer1.frame = CGRect(x: layer.bounds.minX, y: layer.bounds.minY, width: layer.bounds.width, height: scrollMaskSize)
            gradientLayer1.endPoint = CGPoint(x: 0, y: 1)
            
            gradientLayer2.isHidden = false
            gradientLayer2.frame = CGRect(x: layer.bounds.minX, y: layer.bounds.maxY - scrollMaskSize, width: layer.bounds.width, height: scrollMaskSize)
            gradientLayer2.startPoint = CGPoint(x: 0, y: 1)

        case .horizontal:
            gradientLayer1.isHidden = false
            gradientLayer1.frame = CGRect(x: layer.bounds.minX, y: layer.bounds.minY, width: scrollMaskSize, height: layer.bounds.height)
            gradientLayer1.endPoint = CGPoint(x: 1, y: 0)

            gradientLayer2.isHidden = false
            gradientLayer2.frame = CGRect(x: layer.bounds.maxX - scrollMaskSize, y: layer.bounds.minY, width: scrollMaskSize, height: layer.bounds.height)
            gradientLayer2.startPoint = CGPoint(x: 1, y: 0)
        }
    }
}
