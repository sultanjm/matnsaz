//
//  SuggestionButton.swift
//  Matnsaz Keyboard
//
//  Created by Zeerak Ahmed on 12/31/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import UIKit

struct Suggestion {
    var text: String
    var isDefault: Bool
    var isUserTypedString: Bool
}

class SuggestionButton: UIButton {
    
    var suggestion: Suggestion?
    var label = UILabel()
    var highlightPath = UIBezierPath()
    var highlightLayer = CAShapeLayer()
    var highlightVisible = false
    
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = Colors.lightModeBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, marginTop: CGFloat, marginLeft: CGFloat, marginRight: CGFloat) {
        
        // frames
        super.frame = CGRect(x: x, y: y, width: width, height: height)
        let labelFrameRect = CGRect(x: 0 + marginLeft,
                                    y: 0 + marginTop,
                                    width: width - marginLeft - marginRight,
                                    height: height - marginTop)
        
        
        // set up label
        self.label.font = UIFont.systemFont(ofSize: CGFloat(height * 0.3))
        self.label.frame = labelFrameRect
        self.label.textAlignment = NSTextAlignment.center
        self.addSubview(self.label)
        
        // set up highlight
        self.highlightPath = UIBezierPath(roundedRect: labelFrameRect, cornerRadius: 8)
        self.highlightLayer.path = self.highlightPath.cgPath
        self.highlightLayer.fillColor = UIColor(white: 1.0, alpha: 1.0).cgColor
    }
    
    func setSuggestion(_ s: Suggestion) {
        self.suggestion = s
        var text = s.text
        if self.suggestion!.isUserTypedString && self.suggestion!.text != "" {
            text = "\"" + text + "\""
        }
        if self.suggestion!.isDefault && !self.suggestion!.isUserTypedString {
            self.showHighlight()
        }
        self.label.text = text
    }
    
    func reset() {
        self.suggestion = nil
        self.label.text = ""
        self.hideHighlight()
    }
    
    func showHighlight() {
        if !self.highlightVisible && self.suggestion != nil {
            self.layer.insertSublayer(self.highlightLayer, below: self.label.layer)
            self.highlightVisible = true
        }
    }
    
    func hideHighlight() {
        if self.highlightVisible {
            self.highlightLayer.removeFromSuperlayer()
            self.highlightVisible = false
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if self.suggestion != nil {
                    self.showHighlight()
                }
            } else {
                self.hideHighlight()
            }
        }
    }
}

