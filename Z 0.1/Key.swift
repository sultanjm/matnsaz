//
//  Key.swift
//  UrduKeyboard
//
//  Created by Zeerak Ahmed on 3/26/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import UIKit

class Key: UIButton {
    
    var type: KeyType
    var popUpPath: UIBezierPath
    var popUpLabel: UILabel
    var popUpBackgroundLayer: CAShapeLayer
    var x, y, width, height: Double
    var title: String
    var cornerRadius = 4.0
    
    enum KeyType {
        case Letter
        case Space
        case Backspace
        case Return
        case KeyboardSelection
        case Number
        case Settings
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
    
    init(type: KeyType, title: String, x: Double, y: Double, width: Double, height: Double) {
        
        // instance setup
        self.type = type
        self.popUpPath = UIBezierPath()
        self.popUpBackgroundLayer = CAShapeLayer()
        self.popUpLabel = UILabel()
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.title = title
        
        // frame & init
        let frameRect = CGRect(x: x, y: y, width: width, height: height)
        super.init(frame: frameRect)
        self.layer.cornerRadius = CGFloat(self.cornerRadius)
        self.clipsToBounds = false
        
        // title
        self.setTitle(title, for: [])
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.titleEdgeInsets = UIEdgeInsets.zero
        self.contentEdgeInsets = UIEdgeInsets.zero
        self.popUpLabel.text = title
        self.popUpLabel.font = UIFont.systemFont(ofSize: 24)
        self.popUpLabel.isHidden = false
        self.popUpLabel.textAlignment = NSTextAlignment.center
      
        // set up popUp
        self.createPopUp()
        
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
        if self.type == KeyType.Number || self.type == KeyType.Settings {
            self.setTitleColor(disabledTextColor, for: [])
        }
    }
    
    func setBackgroundColor(mode:KeyboardColorMode) {
        if mode == KeyboardColorMode.Light {
            if self.type == KeyType.Letter || self.type == KeyType.Space {
                self.backgroundColor = lightModeBackgroundColor
                self.popUpBackgroundLayer.fillColor = lightModeBackgroundColor.cgColor
            } else {
                self.backgroundColor = lightModeSpecialKeyBackgroundColor
            }
        } else {
            if self.type == KeyType.Letter || self.type == KeyType.Space {
                self.backgroundColor = darkModeBackgroundColor
                self.popUpBackgroundLayer.fillColor = darkModeBackgroundColor.cgColor
            } else {
                self.backgroundColor = darkModeSpecialKeyBackgroundColor
            }
        }
    }
    
    func createPopUp() {
        let popUpWidthHang = 8.0
        let popUpHeightHang = 54.0
        let popUpBaselineDistance = 8.0
        let popUpCornerRadius = 8.0
        let popUpTextBaselineOffset = 4.0
        let pi = CGFloat(Double.pi)
        
        self.popUpPath = UIBezierPath.init(
            arcCenter: CGPoint.init(x: self.cornerRadius, y: self.height - self.cornerRadius),
            radius: CGFloat(self.cornerRadius),
            startAngle: pi,
            endAngle: pi/2,
            clockwise: false)
        self.popUpPath.addLine(to: CGPoint.init(x: self.width - self.cornerRadius, y: self.height))
        self.popUpPath.addArc(
            withCenter: CGPoint.init(x: self.width - self.cornerRadius, y: self.height - self.cornerRadius),
            radius: CGFloat(self.cornerRadius),
            startAngle: pi/2,
            endAngle: 0,
            clockwise: false)
        self.popUpPath.addLine(to: CGPoint.init(x: self.width, y: self.cornerRadius))
        self.popUpPath.addCurve(
            to: CGPoint.init(x: self.width + popUpWidthHang, y: -popUpBaselineDistance),
            controlPoint1: CGPoint.init(x: self.width, y: -popUpBaselineDistance/2),
            controlPoint2: CGPoint.init(x: self.width + popUpWidthHang, y: -popUpBaselineDistance/2))
        self.popUpPath.addLine(to: CGPoint.init(x: self.width + popUpWidthHang, y: 0 - popUpHeightHang + popUpCornerRadius))
        self.popUpPath.addArc(
            withCenter: CGPoint.init(x: self.width + popUpWidthHang - popUpCornerRadius, y: 0 - popUpHeightHang + popUpCornerRadius),
            radius: CGFloat(popUpCornerRadius),
            startAngle: 0,
            endAngle: pi * 3/2,
            clockwise: false)
        self.popUpPath.addLine(to: CGPoint.init(x: 0 - popUpWidthHang + popUpCornerRadius, y: 0 - popUpHeightHang))
        self.popUpPath.addArc(
            withCenter: CGPoint.init(x: 0 - popUpWidthHang + popUpCornerRadius, y: 0 - popUpHeightHang + popUpCornerRadius),
            radius: CGFloat(popUpCornerRadius),
            startAngle: pi * 3/2,
            endAngle: pi,
            clockwise: false)
        self.popUpPath.addLine(to: CGPoint.init(x: 0 - popUpWidthHang, y: -popUpBaselineDistance))
        self.popUpPath.addCurve(
            to: CGPoint.init(x: 0, y: self.cornerRadius),
            controlPoint1: CGPoint.init(x: -popUpWidthHang, y: -popUpBaselineDistance/2),
            controlPoint2: CGPoint.init(x: 0, y: -popUpBaselineDistance/2))
        self.popUpPath.close()
        
        self.popUpLabel.frame = CGRect.init(
            origin: CGPoint.init(x: -popUpWidthHang, y: -popUpHeightHang + popUpTextBaselineOffset),
            size: CGSize(width: self.width + 2 * popUpWidthHang, height: popUpHeightHang - popUpBaselineDistance))
        
        self.popUpBackgroundLayer.path = self.popUpPath.cgPath
        self.popUpBackgroundLayer.position = CGPoint(x: 0, y: 0)
    }
    
    func showPopUp() {
        self.layer.addSublayer(self.popUpBackgroundLayer)
        self.addSubview(self.popUpLabel)
    }
    
    func hidePopUp()  {
        self.popUpBackgroundLayer.removeFromSuperlayer()
        self.popUpLabel.removeFromSuperview()
    }
}
