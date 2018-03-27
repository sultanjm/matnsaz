//
//  KeyboardViewController.swift
//  Z 0.1
//
//  Created by Zeerak Ahmed on 2/13/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    var nextKeyboardButton: UIButton!
    var keys: [Key]!
    var spaceTimer: Timer!
    
    var DoubleTapSpaceBarShortcutActive = true
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // custom view sizing constraints
        let expandedHeight:CGFloat = 268.0
        let heightConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0.0, constant: expandedHeight)
        self.view.addConstraint(heightConstraint)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keys = []

        // keyboard selector
        addKey(type: Key.KeyType.KeyboardSelection, title: "🌐", x: 330, y: 222, width: 42, height: 42)
        
        // space
        addKey(type: Key.KeyType.Space, title: "فاصلہ", x: 99, y: 222, width: 129, height: 42)
        
        // backspace
        addKey(type: Key.KeyType.Backspace, title: "→", x: 3.0, y: 169, width: 31.5, height: 42)
        
        // return
        addKey(type: Key.KeyType.Return, title: "⮑", x: 3.0, y: 222, width: 90, height: 42)
        
        // number
        addKey(type: Key.KeyType.Number, title: "123", x: 234, y: 222, width: 42, height: 42)
        
        // settings
        addKey(type: Key.KeyType.Settings, title: "⚙︎", x: 282, y: 222, width: 42, height: 42)
        
        // letters
        addKey(type: Key.KeyType.Letter, title: "ا", x: 340.5, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ب", x: 303.0, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "پ", x: 265.5, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ت", x: 228.0, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ٹ", x: 190.5, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ث", x: 153.0, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ج", x: 115.5, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "چ", x: 78.0, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ح", x: 40.5, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "خ", x: 3.0, y: 10 , width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "د", x: 340.5, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ڈ", x: 303.0, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ذ", x: 265.5, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ر", x: 228.0, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ڑ", x: 190.5, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ز", x: 153.0, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ژ", x: 115.5, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "س", x: 78.0, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ش", x: 40.5, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ص", x: 3.0, y: 63, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ض", x: 340.5, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ط", x: 303.0, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ظ", x: 265.5, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ع", x: 228.0, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "غ", x: 190.5, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ف", x: 153.0, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ق", x: 115.5, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ک", x: 78.0, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "گ", x: 40.5, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ل", x: 3.0, y: 116, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "م", x: 340.5, y: 169, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ن", x: 303.0, y: 169, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ں", x: 265.5, y: 169, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "و", x: 228.0, y: 169, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ہ", x: 190.5, y: 169, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ھ", x: 153.0, y: 169, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ء", x: 115.5, y: 169, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ی", x: 78.0, y: 169, width: 31.5, height: 42)
        addKey(type: Key.KeyType.Letter, title: "ے", x: 40.5, y: 169, width: 31.5, height: 42)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        let proxy = self.textDocumentProxy

        // dark mode
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            for key in self.keys {
                key.handleDarkMode()
            }
        }
    }
    
    func addKey(type: Key.KeyType, title: String, x: Double, y: Double, width: Double, height: Double) {
        let key = Key(type: type, title: title, x: x, y: y, width: width, height: height)
        self.keys.append(key)
        self.view.addSubview(key)
        switch key.type {
        case Key.KeyType.KeyboardSelection:
            key.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            // need something to have autolayout for height to work, should be removed when adding other autolayout stuff
            let guide = inputView!.layoutMarginsGuide
            key.translatesAutoresizingMaskIntoConstraints = false;
            key.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -4.0).isActive = true
            key.rightAnchor.constraint(equalTo: inputView!.rightAnchor, constant: -3.0).isActive = true
            key.widthAnchor.constraint(equalToConstant: 42.0).isActive = true
            key.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        case Key.KeyType.Letter:
            key.addTarget(self, action: #selector(keyTouchUp(sender:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(keyTouchDown(sender:)), for: .touchDown)
        case Key.KeyType.Backspace:
            key.addTarget(self, action: #selector(keyTouchUp(sender:)), for: .touchUpInside)
        default:
            key.addTarget(self, action: #selector(keyTouchUp(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func keyTouchUp(sender: Key) {
        switch sender.type {
        case Key.KeyType.Letter:
            sender.hidePopUp()
            let title = sender.title(for: UIControlState.normal)
            self.textDocumentProxy.insertText(title!)
        case Key.KeyType.Space:
            // "." shortcut
            if DoubleTapSpaceBarShortcutActive {
                let precedingCharacter = self.textDocumentProxy.documentContextBeforeInput?.suffix(1)
                if precedingCharacter == " " {
                    if self.spaceTimer != nil {
                        if self.spaceTimer.isValid {
                            self.textDocumentProxy.deleteBackward()
                            self.textDocumentProxy.insertText("۔")
                            self.spaceTimer.invalidate()
                        }
                    }
                } else if precedingCharacter?.rangeOfCharacter(from: NSCharacterSet.punctuationCharacters) == nil {
                    self.startSpaceTimer()
                }
            }
            self.textDocumentProxy.insertText(" ")
        case Key.KeyType.Backspace:
            self.textDocumentProxy.deleteBackward()
        case Key.KeyType.Return:
            self.textDocumentProxy.insertText("\n")
        default:
            break
        }
    }
    
    @objc func keyTouchDown(sender: Key) {
        switch sender.type {
        case Key.KeyType.Letter:
            sender.showPopUp()
        default:
            break
        }
    }
    
    @objc func allTouchEvents(sender: Key) {
        switch sender.type {
        case Key.KeyType.Backspace:
            self.textDocumentProxy.deleteBackward()
        default:
            break
        }
    }

    func startSpaceTimer() {
        self.spaceTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(spaceTimerFired(timer:)), userInfo: nil, repeats: false)
    }
    
    @objc func spaceTimerFired(timer: Timer) {
        self.spaceTimer.invalidate()
    }
    
}
