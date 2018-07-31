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
    var backspaceTimer: Timer!
    var backspaceCount = 0
    var heightConstraint: NSLayoutConstraint?
    var keyboardMode = KeyboardMode.primary
    
    enum Orientation: String {
        case portrait
        case landscape
    }
    
    enum KeyboardLayouts: String {
        case Alphabetical
        case Rasm
    }
    
    enum KeyboardMode: String {
        case primary
        case secondary
    }
    
    // Config
    var KeyboardLayout = KeyboardLayouts.Alphabetical
    var DoubleTapSpaceBarShortcutActive = true
    var CharacterVariantsEnabled = false
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // custom view sizing constraints
        setHeight()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateViewConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        layoutKeys()
    }
    
    func layoutKeys() {
        // get layout file
        let layoutFileName = KeyboardLayout.rawValue + "-" + self.getDeviceType() + "-layout-" + self.keyboardMode.rawValue
        
        // read plist and update layout
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
    
    func switchKeyboardMode() {
        if self.keyboardMode == KeyboardMode.primary {
            self.keyboardMode = KeyboardMode.secondary
        } else {
            self.keyboardMode = KeyboardMode.primary
        }
        self.layoutKeys()
    }
    
    func getCurrentOrientation() -> Orientation {
        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
            return Orientation.portrait
        } else {
            return Orientation.landscape
        }
    }
    
    func getDeviceType() -> String {
       
        // get modelName
        var modelName: String
        if TARGET_OS_SIMULATOR != 0 {
            modelName = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        } else {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            modelName = String(cString: machine)
        }
        
        // switch model name to model type
        var type: String
        switch modelName {
        case "iPhone3,1", "iPhone3,2", "iPhone3,3", "iPhone4,1", "iPhone5,1", "iPhone5,2", "iPhone5,3", "iPhone5,4", "iPhone6,1", "iPhone6,2", "iPhone8,4":
            type = "small-phone"
        case "iPhone7,2", "iPhone8,1", "iPhone9,1", "iPhone9,3", "iPhone10,1", "iPhone10,4":
            type = "standard-phone"
        case "iPhone7,1", "iPhone8,2", "iPhone9,2", "iPhone9,4", "iPhone10,2", "iPhone10,5":
            type = "plus-phone"
        case "iPhone10,3", "iPhone10,6":
            type = "X-phone"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4", "iPad3,1", "iPad3,2", "iPad3,3", "iPad3,4", "iPad3,5", "iPad3,6", "iPad4,1", "iPad4,2", "iPad4,3", "iPad5,3", "iPad5,4", "iPad6,11", "iPad6,12",  "iPad7,5", "iPad7,6", "iPad2,5", "iPad2,6", "iPad2,7", "iPad4,4", "iPad4,5", "iPad4,6", "iPad4,7", "iPad4,8", "iPad4,9", "iPad5,1", "iPad5,2", "iPad6,3", "iPad6,4":
            type = "standard-tablet"
        case "iPad6,7", "iPad6,8", "iPad7,1", "iPad7,2":
            type = "large-tablet"
        case "iPad7,3", "iPad7,4":
            type = "medium-tablet"
        default:
            type = "unknown"
        }
        
        type += "-" + getCurrentOrientation().rawValue
        return type
    }
    
    func isPhone() -> Bool {
        return getDeviceType().contains("phone")
    }
    
    func isTablet() -> Bool {
        return getDeviceType().contains("tablet")
    }
    
    func setHeight() {
        
        let expandedHeight: CGFloat
        let layoutFileName = KeyboardLayout.rawValue + "-" + getDeviceType() + "-meta"
        
        // read plist
        let path = Bundle.main.path(forResource: layoutFileName, ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) {
            if let height = dict["primary-height"] as? CGFloat {
                expandedHeight = height
                if (self.heightConstraint == nil) {
                    self.heightConstraint = NSLayoutConstraint(item: self.view,
                                                               attribute: NSLayoutAttribute.height,
                                                               relatedBy: NSLayoutRelation.equal,
                                                               toItem: nil,
                                                               attribute: NSLayoutAttribute.notAnAttribute,
                                                               multiplier: 1.0,
                                                               constant: expandedHeight)
                    self.heightConstraint?.priority = UILayoutPriority(rawValue: 999.0)
                    self.heightConstraint?.isActive = true
                } else {
                    self.heightConstraint!.constant = expandedHeight
                }
                self.view.addConstraint(heightConstraint!)
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
        case Key.KeyType.Backspace:
            let cancelEvents: UIControlEvents = [UIControlEvents.touchUpInside, UIControlEvents.touchUpInside, UIControlEvents.touchDragExit, UIControlEvents.touchUpOutside, UIControlEvents.touchCancel, UIControlEvents.touchDragOutside]
            key.addTarget(self, action: #selector(startBackspace(sender:)), for: .touchDown)
            key.addTarget(self, action: #selector(stopBackspace(sender:)), for: cancelEvents)
        default:
            key.addTarget(self, action: #selector(keyTouchUp(sender:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(keyTouchDown(sender:)), for: .touchDown)
            key.addTarget(self, action: #selector(keyDragExit(sender:)), for: .touchDragExit)
        }
    }
    
    @objc func keyTouchUp(sender: Key) {
        // handle input
        switch sender.type {
        case Key.KeyType.Letter,
             Key.KeyType.Number,
             Key.KeyType.Punctuation,
             Key.KeyType.Diacritic:
            if isPhone() {
                sender.hidePopUp()
            }
            var action = sender.label
            mergeHamzaForward(currentChar: sender.label)
            action = mergeHamzaBackward(currentChar: sender.label)
            self.textDocumentProxy.insertText(action)
        case Key.KeyType.SwitchToPrimaryMode,
             Key.KeyType.SwitchToSecondaryMode:
            self.switchKeyboardMode()
        case Key.KeyType.DismissKeyboard:
            self.dismissKeyboard()
        case Key.KeyType.Space:
            let action = " "
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
            self.textDocumentProxy.insertText(action)
        case Key.KeyType.ZeroWidthNonJoiner:
            self.textDocumentProxy.insertText("‌")
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
        case Key.KeyType.Letter,
             Key.KeyType.Number,
             Key.KeyType.Punctuation,
             Key.KeyType.Diacritic:
            if isPhone() {
                sender.showPopUp()
            }
        default:
            break
        }
    }
    
    @objc func keyDragExit(sender: Key) {
        switch sender.type {
        default:
            sender.hidePopUp()
        }
    }
    
    @objc func startBackspace(sender: Key) {
        self.textDocumentProxy.deleteBackward()
        self.backspaceTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(backspaceTimerFired(timer:)), userInfo: nil, repeats: true)
    }

    @objc func stopBackspace(sender: Key) {
        endBackspace()
    }
    
    func endBackspace() {
        self.backspaceTimer.invalidate()
        backspaceCount = 0
    }
    
    @objc func backspaceTimerFired(timer: Timer) {
        if (backspaceCount < 15) {
            self.textDocumentProxy.deleteBackward()
            backspaceCount += 1
        } else {
            if lastCharacter() == " " {
                self.textDocumentProxy.deleteBackward()
            }
            if let words = self.textDocumentProxy.documentContextBeforeInput?.components(separatedBy: " ") {
                let charsToDelete = words.last!.count + 1
                for _ in 1...charsToDelete {
                    self.textDocumentProxy.deleteBackward()
                }
            } else {
                endBackspace()
            }
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
        if lastCharacter() == nil {
            return false
        }
        else {
            var s = String()
            s.append(lastCharacter()!)
            return s.rangeOfCharacter(from: NSCharacterSet.punctuationCharacters) != nil
        }
    }
    
    func mergeHamzaForward(currentChar: String) {
        if inWord() && lastCharacter() == "ء" {
            self.textDocumentProxy.deleteBackward()
            self.textDocumentProxy.insertText("ئ")
        }
    }
    
    func mergeHamzaBackward(currentChar: String) -> String {
        if currentChar != "ء" {
            return currentChar
        }
        switch lastCharacter() {
        case "و":
            self.textDocumentProxy.deleteBackward()
            return "ؤ"
        case "ا":
            self.textDocumentProxy.deleteBackward()
            return "أ"
        default:
            return currentChar
        }
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
        let fileName = KeyboardLayout.rawValue + "-keys"
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
