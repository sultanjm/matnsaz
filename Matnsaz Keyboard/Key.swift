//
//  Key.swift
//  UrduKeyboard
//
//  Created by Zeerak Ahmed on 3/26/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import UIKit

class Key: UIButton {
    
    var name: String
    var type: KeyType
    var buttonLabel: UILabel
    var popUpPath: UIBezierPath
    var popUpLabel: UILabel
    var popUpBackgroundLayer: CAShapeLayer
    var maskLayer: CAShapeLayer
    var maskViewProperty: UIView
    var isVisible: Bool
    var popUpVisible: Bool
    var x = 0.0
    var y = 0.0
    var width = 0.0
    var height = 0.0
    var label: String
    var cornerRadius = 4.0
    var contextualFormsEnabled: Bool
    var mode: KeyboardColorMode
    var keyboardViewController: KeyboardViewController?
    var neighbors: Array<String>?
    
    enum KeyType: String {
        case Letter
        case Space
        case ZeroWidthNonJoiner
        case Backspace
        case Return
        case KeyboardSelection
        case Number
        case SwitchToPrimaryMode
        case SwitchToSecondaryMode
        case DismissKeyboard
        case Punctuation
        case Diacritic
        case Settings
    }
    
    init(name: String, type: KeyType, label: String, contextualFormsEnabled: Bool, keyboardViewController: KeyboardViewController, neighbors: Array<String>?) {
        
        // instance setup
        self.type = type
        self.buttonLabel = UILabel()
        self.popUpPath = UIBezierPath()
        self.popUpBackgroundLayer = CAShapeLayer()
        self.popUpLabel = UILabel()
        self.popUpVisible = false
        self.isVisible = false
        self.maskLayer = CAShapeLayer()
        self.maskViewProperty = UIView()
        self.mode = KeyboardColorMode.Light
        self.keyboardViewController = keyboardViewController
        self.neighbors = neighbors
        
        // other variables
        self.name = name
        self.label = label
        self.contextualFormsEnabled = contextualFormsEnabled
        
        // frame & init
        super.init(frame: CGRect.zero)
        self.layer.cornerRadius = CGFloat(self.cornerRadius)
        self.adjustsImageWhenHighlighted = false
        
        // label placement
        self.setLabels(nextContextualForm: ArabicScript.ContextualForm.Initial)
        
        // shadow
        self.layer.shadowColor = Colors.KeyShadow
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.masksToBounds = false
        
        // colors
        self.setColors()
        
        // popUp shadow
        self.popUpBackgroundLayer.strokeColor = Colors.KeyShadow
        self.popUpBackgroundLayer.lineWidth = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout(x: Double, y: Double, width: Double, height: Double) {
        
        // frame
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        super.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // set up label
        self.buttonLabel.font = UIFont.systemFont(ofSize: CGFloat(self.height * 0.4))
        self.buttonLabel.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // special case alignment for diacritics
        if self.type == KeyType.Diacritic {
            self.buttonLabel.font = UIFont.systemFont(ofSize: CGFloat(self.height * 0.6))
            self.alignDiacritics(label: self.buttonLabel)
        }
        self.addSubview(self.buttonLabel)
        
        // pop up
        self.createPopUp()
        
        self.isVisible = true
    }
    
    func hide() {
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
        self.buttonLabel.removeFromSuperview()
        super.frame = CGRect(x: x, y: y, width: width, height: height)
        self.isVisible = false
    }
    
    func setLabels(nextContextualForm: ArabicScript.ContextualForm) {
        var title = ""
        
        // set contextual forms
        if self.contextualFormsEnabled {
            
            switch self.type {
            case KeyType.Letter:
                var label = self.label
                // special case Hamza label
                if (self.name == "ء" && nextContextualForm == ArabicScript.ContextualForm.Medial) {
                    label = "ئ"
                }
                title = ArabicScript.addTatweelTo(label, toDisplay: nextContextualForm)
            // if turning autosuggest off bring back labels for space and zwnj
            // ref commit 00791e3
            case Key.KeyType.Space,
                 Key.KeyType.ZeroWidthNonJoiner:
                var label = ""
                for button in self.keyboardViewController!.suggestionButtons {
                    if button.suggestion?.isDefault ?? false {
                        label = String(button.suggestion!.text.last!)
                    }
                }
                title = label
            default:
                title = self.label
            }
            
        } else {
            title = self.label
        }
        
        setImages()
        
        self.buttonLabel.textAlignment = NSTextAlignment.center
        self.popUpLabel.textAlignment = NSTextAlignment.center
        self.buttonLabel.text = title
        self.popUpLabel.text = title
    }
    
    func setImages() {
        switch self.type {
        case KeyType.Backspace,
             KeyType.Return,
             KeyType.KeyboardSelection,
             KeyType.DismissKeyboard,
             KeyType.Settings:
            let imageName = self.type.rawValue + "-" + self.mode.rawValue + ".png"
            self.setImage(UIImage(named: imageName), for: UIControl.State.normal)
            self.imageView?.contentMode = .scaleAspectFit
        default:
            break
        }
    }
    
    func setColors() {
        self.setLabelColor()
        self.setBackgroundColor()
        self.setImages()
    }
    
    func handleDarkMode() {
        self.mode = KeyboardColorMode.Dark
        self.setColors()
    }
    
    func setLabelColor() {
        if self.mode == KeyboardColorMode.Light {
            self.buttonLabel.textColor = Colors.lightModeKeyText
            self.popUpLabel.textColor = Colors.lightModeKeyText
        } else {
            self.buttonLabel.textColor = Colors.darkModeKeyText
            self.popUpLabel.textColor = Colors.darkModeKeyText
        }
    }
    
    func setBackgroundColor() {
        if self.mode == KeyboardColorMode.Light {
            if self.isSpecialKey() {
                self.backgroundColor = Colors.lightModeSpecialKeyBackground
            } else {
                self.backgroundColor = Colors.lightModeKeyBackground
                self.popUpBackgroundLayer.fillColor = Colors.lightModeKeyBackground.cgColor
            }
        } else {
            if self.isSpecialKey() {
                self.backgroundColor = Colors.darkModeSpecialKeyBackground
            } else {
                self.backgroundColor = Colors.darkModeKeyBackground
                self.popUpBackgroundLayer.fillColor = Colors.darkModeKeyBackground.cgColor
            }
        }
    }
    
    func createPopUp() {
        let popUpWidthHang = 12.0 // how much the pop up hangs off the side of the key
        
        // adjust width hangs if on the edge of the view
        var popUpWidthHangLeft = popUpWidthHang
        var popUpWidthHangRight = popUpWidthHang
        if self.x < popUpWidthHang {
            popUpWidthHangLeft = 0
            popUpWidthHangRight = 2 * popUpWidthHang
        } else if Double(self.superview!.frame.width) - (self.x + self.width) < popUpWidthHang {
            popUpWidthHangLeft = 2 * popUpWidthHang
            popUpWidthHangRight = 0
        }
        
        let popUpHeightHang = Double(self.keyboardViewController!.popUpHeightHang) // how far in total the pop up goes above the key
        let popUpBaselineDistance = 16.0 // the bottom edge of the pop up (where the corners of the curve are)
        let popUpCornerRadius = 12.0
        let popUpTextBaselineOffset = 4.0 // how much lower than the bottom edge of the pop up the baseline of the text should be
        let pi = CGFloat(Double.pi)
        
        // start at bottom left corner of key
        self.popUpPath = UIBezierPath.init(
            arcCenter: CGPoint.init(x: self.cornerRadius, y: self.height - self.cornerRadius),
            radius: CGFloat(self.cornerRadius),
            startAngle: pi,
            endAngle: pi/2,
            clockwise: false)
        
        // horizontal line to bottom right of key
        self.popUpPath.addLine(to: CGPoint.init(x: self.width - self.cornerRadius, y: self.height))
        
        // arc around bottom right corner
        self.popUpPath.addArc(
            withCenter: CGPoint.init(x: self.width - self.cornerRadius, y: self.height - self.cornerRadius),
            radius: CGFloat(self.cornerRadius),
            startAngle: pi/2,
            endAngle: 0,
            clockwise: false)
        
        // line back up to top right of key
        self.popUpPath.addLine(to: CGPoint.init(x: self.width, y: self.cornerRadius))
        
        // curve to bottom right of pop up
        self.popUpPath.addCurve(
            to: CGPoint.init(x: self.width + popUpWidthHangRight, y: -popUpBaselineDistance),
            controlPoint1: CGPoint.init(x: self.width, y: -popUpBaselineDistance/2),
            controlPoint2: CGPoint.init(x: self.width + popUpWidthHangRight, y: -popUpBaselineDistance/2))
        
        // right edge of pop up
        self.popUpPath.addLine(to: CGPoint.init(x: self.width + popUpWidthHangRight, y: 0 - popUpHeightHang + popUpCornerRadius))
        
        // top right corner of pop up
        self.popUpPath.addArc(
            withCenter: CGPoint.init(x: self.width + popUpWidthHangRight - popUpCornerRadius, y: 0 - popUpHeightHang + popUpCornerRadius),
            radius: CGFloat(popUpCornerRadius),
            startAngle: 0,
            endAngle: pi * 3/2,
            clockwise: false)
        
        // line to top left of pop up
        self.popUpPath.addLine(to: CGPoint.init(x: 0 - popUpWidthHangLeft + popUpCornerRadius, y: 0 - popUpHeightHang))
        
        // top left corner
        self.popUpPath.addArc(
            withCenter: CGPoint.init(x: 0 - popUpWidthHangLeft + popUpCornerRadius, y: 0 - popUpHeightHang + popUpCornerRadius),
            radius: CGFloat(popUpCornerRadius),
            startAngle: pi * 3/2,
            endAngle: pi,
            clockwise: false)
        
        // left edge of pop up
        self.popUpPath.addLine(to: CGPoint.init(x: 0 - popUpWidthHangLeft, y: -popUpBaselineDistance))
        
        // bottom left corner of pop up
        self.popUpPath.addCurve(
            to: CGPoint.init(x: 0, y: self.cornerRadius),
            controlPoint1: CGPoint.init(x: -popUpWidthHangLeft, y: -popUpBaselineDistance/2),
            controlPoint2: CGPoint.init(x: 0, y: -popUpBaselineDistance/2))
        
        // left edge of button
        self.popUpPath.close()
        
        // frame for pop up label
        self.popUpLabel.frame = CGRect.init(
            origin: CGPoint.init(
                x: self.x - popUpWidthHangLeft,
                y: self.y + Double(self.keyboardViewController!.suggestionsViewHeight) - popUpHeightHang + cornerRadius + popUpTextBaselineOffset),
            size: CGSize(width: self.width + 2 * popUpWidthHang, height: popUpHeightHang - cornerRadius - popUpBaselineDistance))
        self.popUpLabel.font = UIFont.systemFont(ofSize: self.popUpLabel.frame.height * 0.6)
        
        if self.type == KeyType.Diacritic {
            self.popUpLabel.font = UIFont.systemFont(ofSize: self.popUpLabel.frame.height * 0.8)
            self.alignDiacritics(label: self.popUpLabel)
        }
        
        // set up pop up view
        self.popUpBackgroundLayer.path = self.popUpPath.cgPath
        self.popUpBackgroundLayer.position = CGPoint(x: self.x, y: self.y + Double(self.keyboardViewController!.suggestionsViewHeight))
        
        // set up mask for rest of keyboard - add rectangle to path
        let maskPath = CGMutablePath()
        maskPath.addPath(self.popUpPath.cgPath)
        maskPath.addRect(CGRect(
            x: CGFloat(-self.x),
            y: CGFloat(-self.y - Double(self.keyboardViewController!.suggestionsViewHeight)),
            width: self.superview!.superview!.bounds.width,
            height: self.superview!.superview!.bounds.height))
        
        // set up layer with alpha to let underneath pass through
        self.maskLayer.path = maskPath
        self.maskLayer.position = CGPoint(x: self.x, y: self.y + Double(self.keyboardViewController!.suggestionsViewHeight))
        self.maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        self.maskLayer.fillColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        self.maskViewProperty.layer.addSublayer(self.maskLayer)
    }
    
    func showPopUp() {
        self.superview?.superview?.mask = self.maskViewProperty
        self.superview?.superview?.superview?.layer.addSublayer(self.popUpBackgroundLayer)
        self.superview?.superview?.superview?.addSubview(self.popUpLabel)
        self.buttonLabel.isHidden = true
        self.popUpVisible = true
    }
    
    func hidePopUp()  {
        if !self.popUpVisible {
            return
        } else {
            self.superview?.superview?.mask = nil
            self.popUpBackgroundLayer.removeFromSuperlayer()
            self.popUpLabel.removeFromSuperview()
            self.buttonLabel.isHidden = false
            self.popUpVisible = false
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                // for some special keys change background color on press
                switch self.type {
                case KeyType.Backspace,
                     KeyType.KeyboardSelection,
                     KeyType.Return,
                     KeyType.DismissKeyboard,
                     KeyType.Settings:
                    if self.mode == KeyboardColorMode.Light {
                        self.backgroundColor = Colors.lightModeKeyBackground
                    } else {
                        self.backgroundColor = Colors.darkModeKeyBackground
                    }
                default:
                    break
                }
            } else {
                // reset all background colors
                setBackgroundColor()
            }
        }
    }
    
    func alignDiacritics(label:UILabel) {
        if ArabicScript.isNastaliqEnabled() {
            switch self.name {
            case "ِ", "ٍ", "ٖ":
                label.frame.origin.y -= CGFloat(label.frame.height * 0.1)
            case "ٓ":
                label.frame.origin.y += CGFloat(label.frame.height * 0.1)
                label.frame.origin.x -= CGFloat(label.frame.width * 0.05)
            default:
                label.frame.origin.y += CGFloat(label.frame.height * 0.1)
            }
        } else {
            switch self.name {
            case "ٓ":
                label.frame.origin.x -= CGFloat(label.frame.width * 0.2)
            default:
                label.frame.origin.x -= CGFloat(label.frame.width * 0.1)
            }
            
        }
    }
    
    func isSpecialKey() -> Bool {
        switch self.type {
        case KeyType.Letter,
             KeyType.Number,
             KeyType.Punctuation,
             KeyType.Diacritic,
             KeyType.Space,
             KeyType.ZeroWidthNonJoiner:
            return false
        default:
            return true
        }
    }
}
