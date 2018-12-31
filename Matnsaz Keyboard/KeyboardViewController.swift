//
//  KeyboardViewController.swift
//  Z 0.1
//
//  Created by Zeerak Ahmed on 2/13/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import UIKit

enum Orientation: String {
    case portrait
    case landscape
}

enum KeyboardLayout: String {
    case Alphabetical
    case MappingToQWERTY
    
    func toUrdu() -> String {
        switch self {
        case .Alphabetical:
            return "حروفِ تہجّی"
        case .MappingToQWERTY:
            return "فونیٹک جوڑ تا QWERTY"
        }
    }
}

enum KeyboardMode: String {
    case primary
    case secondary
}

struct Colors {
    static let lightModeBackgroundColor = UIColor(red: 209/255, green: 212/255, blue: 216/255, alpha: 1)
    static let darkModeBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.01)
}

enum SavedDefaults: String {
    case KeyLayout
    case KeyLabels
}

class KeyboardViewController: UIInputViewController {

    var keys: [Key] = []
    var spaceTimer: Timer!
    var backspaceTimer: Timer!
    var backspaceCount = 0
    var heightConstraint: NSLayoutConstraint?
    var keyboardMode = KeyboardMode.primary
    var colorMode = Key.KeyboardColorMode.Light
    var settingsVC: SettingsViewController!
    let tatweel: Character = "ـ"
    
    // references to keys
    var nextKeyboardButton: UIButton!
    var spaceKey: Key?
    var zeroWidthNonJoinerKey: Key?
    var settingsKey: Key?
    var letterKeys: [String: Key] = [:]
    
    // artificially firing a key if you didn't actually press one
    var artificiallyFiredKey: Key?
    var touchPoint: CGPoint?
    
    // autocorrect object
    var autoCorrect = AutoCorrect()
    
    // Config
    var layout: KeyboardLayout!
    var contextualFormsEnabled: Bool!
    var DoubleTapSpaceBarShortcutActive = true
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // custom view sizing constraints
        self.setHeight()
    }
    
    override func viewDidLoad() {
        
        // boilerplate setup
        super.viewDidLoad()
        
        // read settings
        self.readSettings()
        
        // add transparent view so autolayout works, have to enable user interaction so superview's user interaction also works
        let guide = inputView!.layoutMarginsGuide
        let transparentView = UIView.init(frame: CGRect(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 0, height: 0)))
        self.view.addSubview(transparentView)
        transparentView.isUserInteractionEnabled = true
        transparentView.translatesAutoresizingMaskIntoConstraints = false;
        transparentView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -4.0).isActive = true
        
        // other view setup
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = false
        self.view.backgroundColor = Colors.lightModeBackgroundColor
        
        // set up keys
        self.setUpKeys()
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
            self.colorMode = Key.KeyboardColorMode.Dark
            self.view.backgroundColor = Colors.darkModeBackgroundColor
            for key in self.keys {
                key.handleDarkMode()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateViewConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        self.layoutKeys()
    }
    
    func readSettings() {
        
        // layout
        if let defaultLayout = UserDefaults.standard.value(forKey: SavedDefaults.KeyLayout.rawValue) {
            self.layout = KeyboardLayout.init(rawValue: defaultLayout as! String)
        } else {
            self.layout = KeyboardLayout.Alphabetical
            UserDefaults.standard.set(self.layout.rawValue, forKey: SavedDefaults.KeyLayout.rawValue)
        }
        
        // labels
        if let defaultLabels = UserDefaults.standard.value(forKey: SavedDefaults.KeyLabels.rawValue) {
            self.contextualFormsEnabled = (defaultLabels as! Bool)
        } else {
            self.contextualFormsEnabled = true
            UserDefaults.standard.set(self.contextualFormsEnabled, forKey: SavedDefaults.KeyLabels.rawValue)
        }
    }
    
    func layoutKeys() {
        // get layout file
        let layoutFileName = self.layout.rawValue + "-" + self.getDeviceType() + "-layout-" + self.keyboardMode.rawValue
        
        // read plist and update layout
        let path = Bundle.main.path(forResource: layoutFileName, ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) {
            for key in self.keys {
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
        let layoutFileName = self.layout.rawValue + "-" + getDeviceType() + "-meta"
        
        // read plist
        let path = Bundle.main.path(forResource: layoutFileName, ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) {
            if let height = dict["primary-height"] as? CGFloat {
                expandedHeight = height
                if (self.heightConstraint == nil) {
                    self.heightConstraint = NSLayoutConstraint(item: self.view,
                                                               attribute: NSLayoutConstraint.Attribute.height,
                                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                                               toItem: nil,
                                                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
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
    
    func addKey(name: String, type: Key.KeyType, label: String, neighbors: Array<String>?) {
        let key = Key(name: name, type: type, label: label, contextualFormsEnabled: self.contextualFormsEnabled, keyboardViewController: self, neighbors: neighbors)
        self.keys.append(key)
        self.view.addSubview(key)
        
        // add targets
        switch key.type {
        case Key.KeyType.KeyboardSelection:
            key.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        case Key.KeyType.Backspace:
            let cancelEvents: UIControl.Event = [UIControl.Event.touchUpInside, UIControl.Event.touchUpInside, UIControl.Event.touchDragExit, UIControl.Event.touchUpOutside, UIControl.Event.touchCancel, UIControl.Event.touchDragOutside]
            key.addTarget(self, action: #selector(startBackspace(sender:)), for: .touchDown)
            key.addTarget(self, action: #selector(stopBackspace(sender:)), for: cancelEvents)
        default:
            key.addTarget(self, action: #selector(keyTouchUp(sender:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(keyTouchDown(sender:)), for: .touchDown)
            key.addTarget(self, action: #selector(keyDragExit(sender:)), for: .touchDragExit)
        }
        
        // store references
        switch key.type {
        case Key.KeyType.Space:
            self.spaceKey = key
        case Key.KeyType.ZeroWidthNonJoiner:
            self.zeroWidthNonJoinerKey = key
        case Key.KeyType.Settings:
            self.settingsKey = key
        case Key.KeyType.Letter:
            self.letterKeys[key.name] = key
        default:
            break
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
            var action = sender.name
            mergeHamzaForward(currentChar: sender.name)
            action = mergeHamzaBackward(currentChar: sender.name)
            self.deleteTatweelIfNeeded()
            self.textDocumentProxy.insertText(action)
            if self.contextualFormsEnabled && ArabicScript.isForwardJoining(self.lastCharacter()!) {
                self.textDocumentProxy.insertText(String(tatweel))
            }
            let suggestions = self.autoCorrect.getSuggestions(word: self.currentWord(), keys: letterKeys)
            print(suggestions)
        case Key.KeyType.SwitchToPrimaryMode,
             Key.KeyType.SwitchToSecondaryMode:
            self.switchKeyboardMode()
        case Key.KeyType.DismissKeyboard:
            self.dismissKeyboard()
        case Key.KeyType.Space:
            self.deleteTatweelIfNeeded()
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
            self.deleteTatweelIfNeeded()
            self.textDocumentProxy.insertText("‌")
        case Key.KeyType.Return:
            self.textDocumentProxy.insertText("\n")
        case Key.KeyType.Settings:
            self.showSettings()
        default:
            break
        }
        
        // update titles
        if self.contextualFormsEnabled {
            self.updateKeyTitles()
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
        
        // update titles
        if self.contextualFormsEnabled {
            self.updateKeyTitles()
        }
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
        let text = self.textDocumentProxy.documentContextBeforeInput
        var char = text?.last
        if self.contextualFormsEnabled && char == tatweel && text != nil && text!.count > 1 {
            let index = text!.index(text!.endIndex, offsetBy: -2)
            char = text![index]
        }
        return char
    }
    
    func currentWord() -> String {
        var word = ""
        if let text = self.textDocumentProxy.documentContextBeforeInput {
            var reversed = String(text.reversed())
            reversed = ArabicScript.removeDiacritics(reversed)
            for char in reversed {
                if ArabicScript.isLetter(char) {
                    word += String(char)
                } else {
                    break
                }
            }
        }
        word = String(word.reversed())
        return word
    }
    
    func deleteTatweelIfNeeded() {
        if self.contextualFormsEnabled {
            if self.textDocumentProxy.documentContextBeforeInput?.last == tatweel {
                self.textDocumentProxy.deleteBackward()
            }
        }
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
    
    func followingZeroWidthNonJoiner() -> Bool {
        let lastScalar = lastCharacter()?.unicodeScalars.last
        return lastScalar?.value == 0x200C
    }
    
    func followingPunctuation() -> Bool {
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
        
        // figure out what contextual form the next letter should take
        var nextContextualForm: ArabicScript.ContextualForm
        if lastCharacter() == nil || followingSpace() || followingZeroWidthNonJoiner() || followingPunctuation() {
            nextContextualForm = ArabicScript.ContextualForm.Initial
        } else {
            let precedingCharacter = lastCharacter()
            let precedingLetter = ArabicScript.removeDiacritics(String(precedingCharacter!))
            if ArabicScript.isForwardJoining(precedingLetter.first!) {
                nextContextualForm = ArabicScript.ContextualForm.Medial
            } else {
                nextContextualForm = ArabicScript.ContextualForm.Initial
            }
        }
        
        // set label on every key
        for key in self.keys {
            key.setLabels(nextContextualForm: nextContextualForm)
        }
    }
    
    func setUpKeys() {
        
        // filepath
        let fileName = self.layout.rawValue + "-keys"
        let path = Bundle.main.path(forResource: fileName, ofType: "plist")
        
        // read plist
        if let dict = NSDictionary(contentsOfFile: path!) {
            // create key for every item in dictionary
            for (key, value) in dict {
                let info = value as! Dictionary<String, Any>
                addKey(name: key as! String,
                       type: Key.KeyType(rawValue: info["type"] as! String)!,
                       label: info["label"] as! String,
                       neighbors: info["neighbors"] as? Array<String>)
            }
        }
    }
    
    func hideAllKeys() {
        for key in self.keys {
            key.hide()
        }
    }
    
    func showSettings() {
        // show settings
        self.settingsVC = SettingsViewController.init(frame: self.view.frame, colorMode: self.colorMode)
        self.addChild(settingsVC)
        self.view.addSubview(settingsVC.view)
        self.settingsVC.didMove(toParent: self)
        self.settingsVC.keyboardViewController = self
    }
    
    func hideSettings() {
        
        // hide settings
        self.settingsVC.willMove(toParent: nil)
        self.settingsVC.view.removeFromSuperview()
        self.settingsVC.removeFromParent()
        
        // redo keys
        self.hideAllKeys()
        self.readSettings()
        self.setUpKeys()
    }
    
    func getNearestKeyTo(_ point: CGPoint) -> Key? {
        var minDist = CGFloat.greatestFiniteMagnitude
        var closestKey: Key?
        for key in keys {
            let xDist = point.x - key.center.x
            let yDist = point.y - key.center.y
            let dist = sqrt(xDist * xDist + yDist * yDist)
            if dist < minDist {
                minDist = dist
                closestKey = key
            }
        }
        return closestKey
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        self.touchPoint = touch.preciseLocation(in: self.view)
        self.artificiallyFiredKey = getNearestKeyTo(self.touchPoint!)
        self.artificiallyFiredKey?.sendActions(for: UIControl.Event.touchDown)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let newTouchPoint = touch.preciseLocation(in: self.view)
        let oldDist = hypot(self.touchPoint!.x - self.artificiallyFiredKey!.center.x, self.touchPoint!.y - self.artificiallyFiredKey!.center.y)
        let newDist = hypot(newTouchPoint.x - self.artificiallyFiredKey!.center.x, newTouchPoint.y - self.artificiallyFiredKey!.center.y)
        if newDist - oldDist > CGFloat(self.artificiallyFiredKey!.width)/2 {
            self.artificiallyFiredKey?.sendActions(for: UIControl.Event.touchDragExit)
        } else {
            self.artificiallyFiredKey?.sendActions(for: UIControl.Event.touchUpInside)
        }
    }
}
