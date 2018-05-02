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
    
    enum KeyboardLayouts: String {
        case Alphabetical
        case Rasm
    }
    
    // Config
    var KeyboardLayout = KeyboardLayouts.Rasm
    var DoubleTapSpaceBarShortcutActive = true
    var CharacterVariantsEnabled = false
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // custom view sizing constraints
        let expandedHeight:CGFloat
        switch KeyboardLayout {
        case KeyboardLayouts.Alphabetical:
            expandedHeight = 268.0
        case KeyboardLayouts.Rasm:
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
        setUpKeys(layout: KeyboardLayout)
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
    
    override func viewWillLayoutSubviews() {
        let screenWidth = Int(self.view.frame.width)
        let layoutFileName = KeyboardLayout.rawValue + "Layout-w" + String(describing: screenWidth)
        
        // read plist
        let path = Bundle.main.path(forResource: layoutFileName, ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) {
            for key in keys {
                if let info = dict[key.name] as? Dictionary<String, Double> {
                    key.setLayout(x: info["x"]!, y: info["y"]!, width: info["width"]!, height: info["height"]!)
                } else {
                    key.hide()
                }
            }
        }
    }
    
    func addKey(name: String, type: Key.KeyType, label: String) {
        let key = Key(name: name, type: type, label: label, characterVariantsEnabled: CharacterVariantsEnabled)
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
            let action = sender.label
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
    
    func setUpKeys(layout: KeyboardLayouts) {
        // filepath
        let fileName = KeyboardLayout.rawValue + "Layout-Keys"
        let path = Bundle.main.path(forResource: fileName, ofType: "plist")
        // read plist
        if let dict = NSDictionary(contentsOfFile: path!) {
            // create key for every item in dictionary
            for (key, value) in dict {
                let info = value as! Dictionary<String, String>
                addKey(name: key as! String, type: Key.KeyType(rawValue: info["type"]!)!, label: info["label"]!)
            }
        }
    }
}
