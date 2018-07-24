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
    var popUpPath: UIBezierPath
    var popUpLabel: UILabel
    var popUpBackgroundLayer: CAShapeLayer
    var popUpVisible: Bool
    var x = 0.0
    var y = 0.0
    var width = 0.0
    var height = 0.0
    var label: String
    var cornerRadius = 4.0
    var characterVariantsEnabled: Bool
    
    enum KeyType: String {
        case Letter
        case Space
        case Backspace
        case Return
        case KeyboardSelection
        case Number
        case Settings
        case SwitchToPrimaryMode
        case SwitchToSecondaryMode
        case Punctuation
        case Diacritic
    }
    
    enum KeyboardColorMode {
        case Light
        case Dark
    }
    
    // colors
    let lightModeTextColor = UIColor.black
    let lightModeBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let lightModeSpecialKeyBackgroundColor = UIColor(red: 0.67, green: 0.71, blue: 0.75, alpha: 1.0)
    let darkModeTextColor = UIColor.white
    let darkModeBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.30)
    let darkModeSpecialKeyBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
    let disabledTextColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    
    init(name: String, type: KeyType, label: String, characterVariantsEnabled: Bool) {
        
        // instance setup
        self.type = type
        self.popUpPath = UIBezierPath()
        self.popUpBackgroundLayer = CAShapeLayer()
        self.popUpLabel = UILabel()
        self.popUpVisible = false
        
        // other variables
        self.name = name
        self.label = label
        self.characterVariantsEnabled = characterVariantsEnabled
        
        // frame & init
        let frameRect = CGRect(x: x, y: y, width: width, height: height)
        super.init(frame: frameRect)
        self.layer.cornerRadius = CGFloat(self.cornerRadius)
        self.clipsToBounds = false
        
        // label placement
        self.setTitle(nextInputVariant: ArabicScript.CharacterVariant.Initial)
        self.popUpLabel.isHidden = false
        self.popUpLabel.textAlignment = NSTextAlignment.center
    
        // label fonts
        if ArabicScript.isNastaliqEnabled() {
            self.titleLabel?.font = UIFont(name: "Noto Nastaliq Urdu", size: 14)
            self.titleEdgeInsets = UIEdgeInsetsMake(-8, 0, 0, 0)
            self.popUpLabel.font = UIFont(name: "Noto Nastaliq Urdu", size: 26)
        }
        else {
            self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.popUpLabel.font = UIFont.systemFont(ofSize: 26)
        }
        
        // shadow
        let shadowColor = UIColor(red: 0.1, green: 0.15, blue: 0.06, alpha: 0.36).cgColor
        self.layer.shadowColor = shadowColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.masksToBounds = false
        
        // colors
        self.setColors(mode: KeyboardColorMode.Light)
        
        // popUp shadow
        self.popUpBackgroundLayer.strokeColor = shadowColor
        self.popUpBackgroundLayer.lineWidth = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        super.frame = CGRect(x: x, y: y, width: width, height: height)
        self.createPopUp()
    }
    
    func hide() {
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
        super.frame = CGRect(x: x, y: y, width: width, height: height)
    }

    func setTitle(nextInputVariant: ArabicScript.CharacterVariant) {
        var title: String
        
        // set character variants
        if self.characterVariantsEnabled && self.type == KeyType.Letter {
            title = ArabicScript.getCharacterVariant(string: self.label, variant: nextInputVariant)
        } else {
            title = self.label
        }

        // set button images
        switch self.type {
        case KeyType.Backspace:
            title = ""
            self.setImage(UIImage(named: "Backspace.png"), for: UIControlState.normal)
            self.imageView?.contentMode = .scaleAspectFit
        case KeyType.Return:
            title = ""
            self.setImage(UIImage(named: "Return.png"), for: UIControlState.normal)
            self.imageView?.contentMode = .scaleAspectFit
        case KeyType.KeyboardSelection:
            title = ""
            self.setImage(UIImage(named: "Globe.png"), for: UIControlState.normal)
            self.imageView?.contentMode = .scaleAspectFit
        case KeyType.Settings:
            title = ""
            self.setImage(UIImage(named: "Settings.png"), for: UIControlState.normal)
            self.imageView?.contentMode = .scaleAspectFit
        default:
            break
        }
        
        self.setTitle(title, for: [])
        self.popUpLabel.text = title
    }
    
    func setColors(mode: KeyboardColorMode) {
        self.setTitleColor(mode: mode)
        self.setBackgroundColor(mode: mode)
    }
    
    func handleDarkMode() {
        self.setColors(mode: KeyboardColorMode.Dark)
    }
    
    func setTitleColor(mode:KeyboardColorMode) {
        if mode == KeyboardColorMode.Light {
            self.setTitleColor(lightModeTextColor, for:[])
            self.popUpLabel.textColor = lightModeTextColor
        } else {
            self.setTitleColor(darkModeTextColor, for: [])
            self.popUpLabel.textColor = darkModeTextColor
        }
        if self.type == KeyType.Settings {
            self.setTitleColor(disabledTextColor, for: [])
        }
    }
    
    func setBackgroundColor(mode:KeyboardColorMode) {
        if mode == KeyboardColorMode.Light {
            if self.type == KeyType.Letter || self.type == KeyType.Number || self.type == KeyType.Punctuation || self.type == KeyType.Diacritic || self.type == KeyType.Space {
                self.backgroundColor = lightModeBackgroundColor
                self.popUpBackgroundLayer.fillColor = lightModeBackgroundColor.cgColor
            } else {
                self.backgroundColor = lightModeSpecialKeyBackgroundColor
            }
        } else {
            if self.type == KeyType.Letter || self.type == KeyType.Number || self.type == KeyType.Punctuation || self.type == KeyType.Diacritic || self.type == KeyType.Space {
                self.backgroundColor = darkModeBackgroundColor
                self.popUpBackgroundLayer.fillColor = darkModeBackgroundColor.cgColor
            } else {
                self.backgroundColor = darkModeSpecialKeyBackgroundColor
            }
        }
    }
    
    func createPopUp() {
        let popUpWidthHang = 12.0 // how much the pop up hangs off the side of the key
        let popUpHeightHang = max(self.height, self.width) + 18.0 // how far in total the pop up goes above the key
        let popUpBaselineDistance = 16.0 // the bottom edge of the pop up (where the corners of the curve are)
        let popUpCornerRadius = 12.0
        let popUpTextBaselineOffset = -0.0 // how much lower than the bottom edge of the pop up the baseline of the text should be
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
            to: CGPoint.init(x: self.width + popUpWidthHang, y: -popUpBaselineDistance),
            controlPoint1: CGPoint.init(x: self.width, y: -popUpBaselineDistance/2),
            controlPoint2: CGPoint.init(x: self.width + popUpWidthHang, y: -popUpBaselineDistance/2))
        
        // right edge of pop up
        self.popUpPath.addLine(to: CGPoint.init(x: self.width + popUpWidthHang, y: 0 - popUpHeightHang + popUpCornerRadius))
        
        // top right corner of pop up
        self.popUpPath.addArc(
            withCenter: CGPoint.init(x: self.width + popUpWidthHang - popUpCornerRadius, y: 0 - popUpHeightHang + popUpCornerRadius),
            radius: CGFloat(popUpCornerRadius),
            startAngle: 0,
            endAngle: pi * 3/2,
            clockwise: false)
        
        // line to top left of pop up
        self.popUpPath.addLine(to: CGPoint.init(x: 0 - popUpWidthHang + popUpCornerRadius, y: 0 - popUpHeightHang))
        
        // top left corner
        self.popUpPath.addArc(
            withCenter: CGPoint.init(x: 0 - popUpWidthHang + popUpCornerRadius, y: 0 - popUpHeightHang + popUpCornerRadius),
            radius: CGFloat(popUpCornerRadius),
            startAngle: pi * 3/2,
            endAngle: pi,
            clockwise: false)
        
        // left edge of pop up
        self.popUpPath.addLine(to: CGPoint.init(x: 0 - popUpWidthHang, y: -popUpBaselineDistance))
        
        // bottom left corner of pop up
        self.popUpPath.addCurve(
            to: CGPoint.init(x: 0, y: self.cornerRadius),
            controlPoint1: CGPoint.init(x: -popUpWidthHang, y: -popUpBaselineDistance/2),
            controlPoint2: CGPoint.init(x: 0, y: -popUpBaselineDistance/2))
        
        // left edge of button
        self.popUpPath.close()
        
        // frame for pop up label
        self.popUpLabel.frame = CGRect.init(
            origin: CGPoint.init(x: -popUpWidthHang, y: -popUpHeightHang + cornerRadius + popUpTextBaselineOffset),
            size: CGSize(width: self.width + 2 * popUpWidthHang, height: popUpHeightHang - cornerRadius - popUpBaselineDistance))
        
        self.popUpBackgroundLayer.path = self.popUpPath.cgPath
        self.popUpBackgroundLayer.position = CGPoint(x: 0, y: 0)
    }
    
    func showPopUp() {
        self.layer.addSublayer(self.popUpBackgroundLayer)
        self.addSubview(self.popUpLabel)
        self.superview?.bringSubview(toFront: self)
        self.popUpVisible = true
    }
    
    func hidePopUp()  {
        if !self.popUpVisible {
            return
        } else {
            self.popUpBackgroundLayer.removeFromSuperlayer()
            self.popUpLabel.removeFromSuperview()
            self.popUpVisible = false
        }
    }
}
