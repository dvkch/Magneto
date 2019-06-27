//
//  SYGradientView.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

@objcMembers
public class SYGradientView: UIView {
    public override static var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    public var layoutSubviewsBlock: ((SYGradientView) -> ())?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsBlock?(self)
    }
}
