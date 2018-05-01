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
    
    enum KeyboardLayouts {
        case Alphabetical
        case RasmBased
    }
    
    // Config
    var KeyboardLayout = KeyboardLayouts.Alphabetical
    var DoubleTapSpaceBarShortcutActive = true
    var CharacterVariantsEnabled = false
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // custom view sizing constraints
        let expandedHeight:CGFloat
        switch KeyboardLayout {
        case KeyboardLayouts.Alphabetical:
            expandedHeight = 268.0
        case KeyboardLayouts.RasmBased:
            expandedHeight = 215.0
        }
        let heightConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0.0, constant: expandedHeight)
        self.view.addConstraint(heightConstraint)
    }
    
    override func viewDidLoad() {
        // boilerplate setup
        super.viewDidLoad()
        
        // add transparent view so autolayout works
        let guide = inputView!.layoutMarginsGuide
        let transparentView = UIView.init(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 0, height: 0)))
        self.view.addSubview(transparentView)
        transparentView.translatesAutoresizingMaskIntoConstraints = false;
        transparentView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -4.0).isActive = true
        
        // set up keys
        self.keys = []
        switch KeyboardLayout {
        case KeyboardLayouts.Alphabetical:
            setUpAlphabeticalKeyLayout()
        case KeyboardLayouts.RasmBased:
            setUpRasmBasedLayout()
        }
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
    
    func addKey(type: Key.KeyType, action: String, x: Double, y: Double, width: Double, height: Double) {
        let key = Key(type: type, action: action, x: x, y: y, width: width, height: height, characterVariantsEnabled: CharacterVariantsEnabled)
        self.keys.append(key)
        self.view.addSubview(key)
        switch key.type {
        case Key.KeyType.KeyboardSelection:
            key.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
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
        // handle input
        switch sender.type {
        case Key.KeyType.Letter:
            sender.hidePopUp()
            let action = sender.action
            self.textDocumentProxy.insertText(action)
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
        
        // update titles
        if CharacterVariantsEnabled {
            updateKeyTitles()
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
    
    func lastCharacter() -> Optional<Character> {
        return self.textDocumentProxy.documentContextBeforeInput?.last
    }
    
    func inWord() -> Bool {
        if followingSpace() {
            return false
        }
        if followingPunctuation() {
            return false
        }
        return true
    }
    
    func followingSpace() -> Bool {
        return lastCharacter() == " "
    }
    
    func followingPunctuation() -> Bool {
        var s = String()
        s.append(lastCharacter()!)
        return s.rangeOfCharacter(from: NSCharacterSet.punctuationCharacters) != nil
    }
    
    func updateKeyTitles() {
        var nextVariant: ArabicScript.CharacterVariant
        if lastCharacter() == nil {
            nextVariant = ArabicScript.CharacterVariant.Initial
        } else {
            var lastChar = String()
            lastChar.append(lastCharacter()!)
            if followingSpace() {
                nextVariant = ArabicScript.CharacterVariant.Initial
            }
            if inWord() {
                let precedingCharMedial = ArabicScript.getCharacterVariant(string: lastChar, variant: ArabicScript.CharacterVariant.Medial)
                let precedingCharFinal = ArabicScript.getCharacterVariant(string: lastChar, variant: ArabicScript.CharacterVariant.Final)
                if precedingCharMedial == precedingCharFinal {
                    nextVariant = ArabicScript.CharacterVariant.Initial
                } else {
                    nextVariant = ArabicScript.CharacterVariant.Medial
                }
            }
            else {
                nextVariant = ArabicScript.CharacterVariant.Initial
            }
        }
        for key in keys {
            key.setTitle(nextInputVariant: nextVariant)
        }
    }
    
    func setUpAlphabeticalKeyLayout() {
        
        // read plist
        let path = Bundle.main.path(forResource: "AlphabeticalLayout", ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) {
            for (_, value) in dict {
                
                // for every key in the dictionary set up values
                let info = value as! Dictionary<String, Any>
                let action = info["action"] as! String
                let type = Key.KeyType(rawValue: info["type"] as! String)!
                let x = info["x"] as! Double
                let y = info["y"] as! Double
                let width = info["width"] as! Double
                let height = info["height"] as! Double
                
                // add key
                addKey(type: type, action: action, x: x, y: y, width: width, height: height)
            }
        }
    }
    
    func setUpRasmBasedLayout() {
        addKey(type: Key.KeyType.KeyboardSelection, action: "🌐", x: 324, y: 169, width: 48, height: 42)
        addKey(type: Key.KeyType.Number, action: "۱۲۳", x: 269, y: 169, width: 48, height: 42)
        addKey(type: Key.KeyType.Space, action: "فاصلہ", x: 100, y: 169, width: 162, height: 42)
        addKey(type: Key.KeyType.Return, action: "⮑", x: 3, y: 169, width: 90, height: 42)
        addKey(type: Key.KeyType.Settings, action: "⚙︎", x: 324, y: 115, width: 48, height: 42)
        addKey(type: Key.KeyType.Backspace, action: "→", x: 3, y: 115, width: 48, height: 42)
        
        addKey(type: Key.KeyType.Letter, action: "ا", x: 332, y: 10 , width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ٮ", x: 285, y: 10 , width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ح", x: 238, y: 10 , width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "د", x: 191, y: 10, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ر", x: 144, y: 10, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "س", x: 97, y: 10, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ص", x: 50, y: 10, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ط", x: 3, y: 10, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ع", x: 332, y: 63, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ڡ", x: 285, y: 63, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ٯ", x: 238, y: 63, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ک", x: 191, y: 63, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ل", x: 144, y: 63, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "م", x: 97, y: 63, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ں", x: 50, y: 63, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "و", x: 3, y: 63, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ہ", x: 261.5, y: 116, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ھ", x: 214.5, y: 116, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ء", x: 167.5, y: 116, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ی", x: 120.5, y: 116, width: 40, height: 42)
        addKey(type: Key.KeyType.Letter, action: "ے", x: 73.5, y: 116, width: 40, height: 42)
    }
}
