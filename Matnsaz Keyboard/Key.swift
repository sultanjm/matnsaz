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
    
    enum KeyboardColorMode: String {
        case Light
        case Dark
    }
    
    struct Colors {
        static let lightModeTextColor = UIColor.black
        static let lightModeBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        static let lightModeSpecialKeyBackgroundColor = UIColor(red: 0.67, green: 0.71, blue: 0.75, alpha: 1.0)
        static let darkModeTextColor = UIColor.white
        static let darkModeBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.30)
        static let darkModeSpecialKeyBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
        static let disabledTextColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        static let shadowColor = UIColor(red: 0.1, green: 0.15, blue: 0.06, alpha: 0.36).cgColor
    }
    
    init(name: String, type: KeyType, label: String, contextualFormsEnabled: Bool, keyboardViewController: KeyboardViewController) {
        
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
        self.layer.shadowColor = Colors.shadowColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.masksToBounds = false
        
        // colors
        self.setColors()
        
        // popUp shadow
        self.popUpBackgroundLayer.strokeColor = Colors.shadowColor
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
            case KeyType.Space,
                 KeyType.ZeroWidthNonJoiner:
                let lastCharacter = self.keyboardViewController?.lastCharacter()
                if (lastCharacter != nil) {
                    // only display label on space and zwnj if the last character is a letter whose form will change
                    if ArabicScript.isLetter(lastCharacter!) && ArabicScript.isForwardJoining(lastCharacter!) {
                        var formToDisplay = ArabicScript.ContextualForm.Final
                        let text = self.keyboardViewController!.textDocumentProxy.documentContextBeforeInput!
                        // if first character in string just display isolated form
                        if text.count == 1 {
                            formToDisplay = ArabicScript.ContextualForm.Isolated
                        }
                        // otherwise display final, but change to isolated if character before is not forward joining
                        else {
                            let secondLastChar = text[text.index(text.endIndex, offsetBy: -2)]
                            if (!ArabicScript.isForwardJoining(secondLastChar)) {
                                formToDisplay = ArabicScript.ContextualForm.Isolated
                            }
                        }
                        title = ArabicScript.addTatweelTo(String(lastCharacter!), toDisplay: formToDisplay)
                    }
                }
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
            self.buttonLabel.textColor = Colors.lightModeTextColor
            self.popUpLabel.textColor = Colors.lightModeTextColor
        } else {
            self.buttonLabel.textColor = Colors.darkModeTextColor
            self.popUpLabel.textColor = Colors.darkModeTextColor
        }
    }
    
    func setBackgroundColor() {
        if self.mode == KeyboardColorMode.Light {
            if self.isSpecialKey() {
                self.backgroundColor = Colors.lightModeSpecialKeyBackgroundColor
            } else {
                self.backgroundColor = Colors.lightModeBackgroundColor
                self.popUpBackgroundLayer.fillColor = Colors.lightModeBackgroundColor.cgColor
            }
        } else {
            if self.isSpecialKey() {
                self.backgroundColor = Colors.darkModeSpecialKeyBackgroundColor
            } else {
                self.backgroundColor = Colors.darkModeBackgroundColor
                self.popUpBackgroundLayer.fillColor = Colors.darkModeBackgroundColor.cgColor
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
        
        let popUpHeightHang = max(self.height, self.width) + 18.0 // how far in total the pop up goes above the key
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
            origin: CGPoint.init(x: self.x - popUpWidthHangLeft, y: self.y - popUpHeightHang + cornerRadius + popUpTextBaselineOffset),
            size: CGSize(width: self.width + 2 * popUpWidthHang, height: popUpHeightHang - cornerRadius - popUpBaselineDistance))
        self.popUpLabel.font = UIFont.systemFont(ofSize: self.popUpLabel.frame.height * 0.6)
        
        if self.type == KeyType.Diacritic {
            self.popUpLabel.font = UIFont.systemFont(ofSize: self.popUpLabel.frame.height * 0.8)
            self.alignDiacritics(label: self.popUpLabel)
        }
        
        // set up pop up view
        self.popUpBackgroundLayer.path = self.popUpPath.cgPath
        self.popUpBackgroundLayer.position = CGPoint(x: self.x, y: self.y)
        
        // set up mask for rest of keyboard - add rectangle to path
        let maskPath = CGMutablePath()
        maskPath.addPath(self.popUpPath.cgPath)
        maskPath.addRect(CGRect(x: CGFloat(-self.x), y: CGFloat(-self.y), width: self.superview!.bounds.width, height: self.superview!.bounds.height))
        
        // set up layer with alpha to let underneath pass through
        self.maskLayer.path = maskPath
        self.maskLayer.position = CGPoint(x: self.x, y: self.y)
        self.maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        self.maskLayer.fillColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        self.maskViewProperty.layer.addSublayer(self.maskLayer)
    }
    
    func showPopUp() {
        self.superview?.mask = self.maskViewProperty
        self.superview?.superview?.layer.addSublayer(self.popUpBackgroundLayer)
        self.superview?.superview?.addSubview(self.popUpLabel)
        self.buttonLabel.isHidden = true
        self.popUpVisible = true
    }
    
    func hidePopUp()  {
        if !self.popUpVisible {
            return
        } else {
            self.superview?.mask = nil
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
                        self.backgroundColor = Colors.lightModeBackgroundColor
                    } else {
                        self.backgroundColor = Colors.darkModeBackgroundColor
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
