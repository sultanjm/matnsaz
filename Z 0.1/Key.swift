//
//  Key.swift
//  UrduKeyboard
//
//  Created by Zeerak Ahmed on 3/26/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import UIKit

class Key: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var type: KeyType
    
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
        
        // frame & init
        let frameRect = CGRect(x: x, y: y, width: width, height: height)
        super.init(frame: frameRect)
        self.layer.cornerRadius = 4
        
        // title
        self.setTitle(title, for: [])
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.titleEdgeInsets = UIEdgeInsets.zero
        self.contentEdgeInsets = UIEdgeInsets.zero
        
        // shadow
        self.layer.shadowColor = UIColor(red: 0.1, green: 0.15, blue: 0.06, alpha: 0.36).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.masksToBounds = false
        
        // colors
        self.setColors(mode: KeyboardColorMode.Light)
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
        } else {
            self.setTitleColor(darkModeTextColor, for: [])
        }
        if self.type == KeyType.Number || self.type == KeyType.Settings {
            self.setTitleColor(disabledTextColor, for: [])
        }
    }
    
    func setBackgroundColor(mode:KeyboardColorMode) {
        if mode == KeyboardColorMode.Light {
            if self.type == KeyType.Letter || self.type == KeyType.Space {
                self.backgroundColor = lightModeBackgroundColor
            } else {
                self.backgroundColor = lightModeSpecialKeyBackgroundColor
            }
        } else {
            if self.type == KeyType.Letter || self.type == KeyType.Space {
                self.backgroundColor = darkModeBackgroundColor
            } else {
                self.backgroundColor = darkModeSpecialKeyBackgroundColor
            }
        }
    }
}


//var path = UIBezierPath()
//let bottomKey = UIBezierPath.init(roundedRect: CGRect.init(x: 301, y: 226, width: 32, height: 42), cornerRadius: 4)
//let topKey = UIBezierPath.init(roundedRect: CGRect.init(x: 291, y: 184, width: 52, height: 42), cornerRadius: 4)
//path.append(bottomKey)
//path.append(topKey)
//UIColor.purple.setStroke()
//path.stroke()
//let shapeLayer = CAShapeLayer()
//shapeLayer.path = path.cgPath
//self.view.layer.addSublayer(shapeLayer)

