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

enum KeyboardColorMode: String {
    case Light
    case Dark
}

struct Colors {
    // background
    static let lightModeBackground = UIColor(red: 208/255, green: 211/255, blue: 216/255, alpha: 1)
    static let darkModeBackground = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.01)
    // suggestions
    static let lightModeSuggestionDivider = UIColor(red: 177/255, green: 180/255, blue: 186/255, alpha: 1.0)
    static let darkModeSuggestionDivider = UIColor(white: 1.0, alpha: 0.06)
    // keys
    static let lightModeKeyText = UIColor.black
    static let lightModeKeyBackground = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let lightModeSpecialKeyBackground = UIColor(red: 0.67, green: 0.71, blue: 0.75, alpha: 1.0)
    static let darkModeKeyText = UIColor.white
    static let darkModeKeyBackground = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.30)
    static let darkModeSpecialKeyBackground = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
    static let disabledKeyText = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    static let KeyShadow = UIColor(red: 0.1, green: 0.15, blue: 0.06, alpha: 0.36).cgColor
}

enum SavedDefaults: String {
    case KeyLayout
    case KeyLabels
}

class KeyboardViewController: UIInputViewController {

    // basic components
    var keys: [Key] = []
    var keyboardMode = KeyboardMode.primary
    var colorMode = KeyboardColorMode.Light
    
    // dimensions
    var heightConstraint: NSLayoutConstraint?
    var viewHeight: CGFloat!
    var keysViewHeight: CGFloat!
    var suggestionsViewX: CGFloat!
    var suggestionsViewY: CGFloat!
    var suggestionsViewWidth: CGFloat!
    var suggestionsViewHeight: CGFloat!
    var suggestionsMarginTop: CGFloat!
    var suggestionsMarginSide: CGFloat!
    var popUpHeightHang: CGFloat!
    
    // views and view controllers
    var keysView: UIView!
    var suggestionsView: UIView!
    var settingsVC: SettingsViewController!
    
    // references to keys
    var keyboardSelectionKey: Key?
    var spaceKey: Key?
    var zeroWidthNonJoinerKey: Key?
    var settingsKey: Key?
    var letterKeys: [String: Key] = [:]
    
    // timers and counts
    var spaceTimer: Timer!
    var backspaceTimer: Timer?
    var backspaceCount = 0
    
    // suggestions
    var suggestionButtons: [SuggestionButton] = []
    var leftDividerLayer = CAShapeLayer()
    var rightDividerLayer = CAShapeLayer()
    var leftDividerVisible = false
    var rightDividerVisible = false
    
    // active key
    var activeKey: Key?
    
    // autocorrect object
    var autoCorrect = AutoCorrect()
    
    // touch array for autocorrect
    var touchPoints: [CGPoint] = []
    
    // Config
    var layout: KeyboardLayout!
    var contextualFormsEnabled: Bool!
    var DoubleTapSpaceBarShortcutActive = true
    
    // random helper
    let tatweel: Character = "ـ"
    
    //
    //  View Controller Setup
    //
    
    override func viewDidLoad() {
        
        // boilerplate setup
        super.viewDidLoad()
        
        // view setup
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = false
        self.view.backgroundColor = Colors.lightModeBackground
        
        // set up key views
        self.keysView = UIView(frame: CGRect.zero)
        self.keysView.isUserInteractionEnabled = true
        self.keysView.isMultipleTouchEnabled = false
        self.view.addSubview(self.keysView)
        
        // set up suggestions views
        self.suggestionsView = UIView(frame: CGRect.zero)
        self.suggestionsView.isUserInteractionEnabled = true
        self.suggestionsView.isMultipleTouchEnabled = false
        self.view.addSubview(self.suggestionsView)
        
        // add transparent view so autolayout works, have to enable user interaction so superview's user interaction also works
        let transparentView = UIView.init(frame: CGRect(
            origin: CGPoint.init(x: 0, y: 0),
            size: CGSize.init(width: 0, height: 0)))
        self.view.addSubview(transparentView)
        transparentView.isUserInteractionEnabled = true
        transparentView.translatesAutoresizingMaskIntoConstraints = false;
        transparentView.bottomAnchor.constraint(equalTo: inputView!.layoutMarginsGuide.bottomAnchor, constant: -4.0).isActive = true
        
        // read settings
        self.readSettings()
        self.updateViewConstraints()
        
        // set up buttons
        self.setUpKeys()
        self.setUpSuggestionButtons()
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
        self.updateSuggestions()
        if self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearance.dark {
            self.colorMode = KeyboardColorMode.Dark
            self.setSuggestionDividerColors()
            self.view.backgroundColor = Colors.darkModeBackground
            for key in self.keys { key.handleDarkMode() }
            for button in self.suggestionButtons { button.handleDarkMode() }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateViewConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        self.layoutKeys()
        self.layoutSuggestions()
    }
    
    override func updateViewConstraints() {
        self.setDimensions()
        self.updateHeightConstraint()
        super.updateViewConstraints()
    }
    
    //
    //  General Keyboard Setup
    //
    
    func setDimensions() {
        let layoutFileName = self.layout.rawValue + "-" + self.getDeviceType() + "-meta"
        let path = Bundle.main.path(forResource: layoutFileName, ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) {
            self.keysViewHeight = dict["primary-height"] as? CGFloat
            self.popUpHeightHang = dict["pop-up-height-hang"] as? CGFloat
            let suggestionsDict = dict["suggestions"] as! Dictionary<String, CGFloat>
            self.suggestionsViewX = suggestionsDict["x"]
            self.suggestionsViewY = suggestionsDict["y"]
            self.suggestionsViewWidth = suggestionsDict["width"]
            self.suggestionsViewHeight = suggestionsDict["height"]
            self.viewHeight = self.keysViewHeight + self.suggestionsViewHeight
            self.suggestionsMarginTop = suggestionsDict["margin-top"]
            self.suggestionsMarginSide = suggestionsDict["margin-side"]
        }
        self.keysView.frame = CGRect(origin: CGPoint.init(x: 0, y: self.suggestionsViewHeight),
                                     size: CGSize.init(width: UIScreen.main.bounds.width, height: self.keysViewHeight))
        self.suggestionsView.frame = CGRect(origin: CGPoint.init(x: 0, y: 0),
                                            size: CGSize.init(width: UIScreen.main.bounds.width, height: self.suggestionsViewHeight))
    }
    
    func updateHeightConstraint() {
        if (self.heightConstraint == nil) {
            self.heightConstraint = NSLayoutConstraint(item: self.view,
                                                       attribute: NSLayoutConstraint.Attribute.height,
                                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                                       toItem: nil,
                                                       attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                       multiplier: 1.0,
                                                       constant: self.viewHeight)
            self.heightConstraint?.priority = UILayoutPriority(rawValue: 999.0)
            self.heightConstraint?.isActive = true
        } else {
            self.heightConstraint!.constant = self.viewHeight
        }
        self.view.addConstraint(heightConstraint!)
    }
    
    func switchKeyboardMode() {
        if self.keyboardMode == KeyboardMode.primary {
            self.keyboardMode = KeyboardMode.secondary
        } else {
            self.keyboardMode = KeyboardMode.primary
        }
        self.layoutKeys()
    }
    
    func switchToPrimaryMode() {
        if self.keyboardMode != KeyboardMode.primary {
            self.switchKeyboardMode()
        }
    }
    
    //
    //  Setup Keys
    //
    
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
    
    func addKey(name: String, type: Key.KeyType, label: String, neighbors: Array<String>?) {
        
        let key = Key(name: name, type: type, label: label, contextualFormsEnabled: self.contextualFormsEnabled, keyboardViewController: self, neighbors: neighbors)
        self.keys.append(key)
        self.keysView.addSubview(key)
        
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
        case Key.KeyType.KeyboardSelection:
            self.keyboardSelectionKey = key
        default:
            break
        }
    }
    
    func hideAllKeys() {
        for key in self.keys { key.hide() }
    }
    
    func updateKeyTitles() {
        
        // figure out what contextual form the next letter should take
        var nextContextualForm: ArabicScript.ContextualForm
        if lastCharacter() == nil || followingSpace() || followingZeroWidthNonJoiner() || followingPunctuation() {
            nextContextualForm = ArabicScript.ContextualForm.Initial
        }
        else if ArabicScript.removeDiacritics(String(lastCharacter()!)).count == 0 {
            nextContextualForm = ArabicScript.ContextualForm.Initial
        }
        else {
            let precedingLetter = ArabicScript.removeDiacritics(String(lastCharacter()!))
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
    
    //
    //  Deal with touches to keyboard view
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchPoint = touch.preciseLocation(in: self.keysView)
        self.highlightNearestKey(touchPoint: touchPoint)
        self.keyTouchDown(sender: self.activeKey, event: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeKey?.unHighlight()
        self.keyTouchUp(sender: self.activeKey, touches: touches, event: event)
        self.activeKey = nil
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchPoint = touch.preciseLocation(in: self.keysView)
        self.highlightNearestKey(touchPoint: touchPoint)
        self.keyTouchDown(sender: self.activeKey, event: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.activeKey?.unHighlight()
        self.activeKey = nil
    }
    
    func highlightNearestKey(touchPoint: CGPoint) {
        if touchPoint.y < 0 {
            self.activeKey?.unHighlight()
            self.activeKey = nil
            return
        }
        let nearestKey = getNearestKeyTo(touchPoint)
        if nearestKey != self.activeKey {
            self.activeKey?.unHighlight()
            self.activeKey = nearestKey
            self.activeKey?.highlight()
        }
    }
    
    //
    //  Key Interactions
    //
    
    @objc func keyTouchUp(sender: Key?, touches: Set<UITouch>, event: UIEvent?) {
        
        if sender == nil { return }
        
        switch sender!.type {
        
        case Key.KeyType.Letter:
            let action = sender!.name
            mergeHamzaForward(currentChar: sender!.name)
            self.deleteTatweelIfNeeded()
            self.textDocumentProxy.insertText(action)
            if self.contextualFormsEnabled && ArabicScript.isForwardJoining(self.lastCharacter()!) {
                self.textDocumentProxy.insertText(String(tatweel))
            }
            self.touchPoints.append(touches.first!.preciseLocation(in: self.keysView))
            self.updateSuggestions()
            
        case Key.KeyType.Number:
            let action = sender!.name
            self.deleteTatweelIfNeeded()
            self.textDocumentProxy.insertText(action)
            self.updateSuggestions()
            
        case Key.KeyType.Diacritic:
            let action = sender!.name
            self.textDocumentProxy.insertText(action)
        
        case Key.KeyType.Punctuation:
            sender!.hidePopUp()
            let action = sender!.name
            self.deleteTatweelIfNeeded()
            self.insertDefaultSuggestedWord()
            self.textDocumentProxy.insertText(action)
            self.resetSuggestions()
            
        case Key.KeyType.SwitchToPrimaryMode,
             Key.KeyType.SwitchToSecondaryMode:
            self.switchKeyboardMode()
        
        case Key.KeyType.DismissKeyboard:
            self.dismissKeyboard()
        
        case Key.KeyType.Space:
            self.deleteTatweelIfNeeded()
            
            // "." shortcut
            if DoubleTapSpaceBarShortcutActive {
                if lastCharacter() == " " {
                    if self.spaceTimer != nil {
                        if self.spaceTimer.isValid {
                            self.textDocumentProxy.deleteBackward()
                            self.textDocumentProxy.insertText("۔")
                            self.spaceTimer.invalidate()
                        }
                    }
                } else if lastCharacter() != nil && String(lastCharacter()!).rangeOfCharacter(from: NSCharacterSet.punctuationCharacters) == nil {
                    self.startSpaceTimer()
                }
            }
            
            self.insertDefaultSuggestedWord()
            self.textDocumentProxy.insertText(" ")
            self.resetSuggestions()
            self.switchToPrimaryMode()
            self.touchPoints.removeAll()
        
        case Key.KeyType.ZeroWidthNonJoiner:
            self.deleteTatweelIfNeeded()
            self.textDocumentProxy.insertText("‌")
            self.updateSuggestions()
        
        case Key.KeyType.Return:
            self.textDocumentProxy.insertText("\n")
            self.resetSuggestions()
            self.touchPoints.removeAll()
        
        case Key.KeyType.Settings:
            self.showSettings()
        
        case Key.KeyType.Backspace:
            self.stopBackspace()
        
        default:
            break
        }

        if self.contextualFormsEnabled { self.updateKeyTitles() }
    }
    
    @objc func keyTouchDown(sender: Key?, event: UIEvent?) {
        if sender == nil { return }
        switch sender!.type {
        case Key.KeyType.Backspace:
            self.startBackspace()
            self.touchPoints.removeAll()
        case Key.KeyType.KeyboardSelection:
            self.handleInputModeList(from: self.keyboardSelectionKey!, with: event!)
        default:
            break
        }
    }
    
    //
    //  Backspace
    //
    
    func startBackspace() {
        if self.textDocumentProxy.documentContextBeforeInput?.count == 0 { return }
        if self.backspaceTimer == nil || !self.backspaceTimer!.isValid {
            self.textDocumentProxy.deleteBackward()
            self.backspaceTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(backspaceTimerFired(timer:)), userInfo: nil, repeats: true)
        }
    }

    func stopBackspace() {
        self.backspaceTimer?.invalidate()
        self.backspaceCount = 0
        self.updateSuggestions()
        if self.contextualFormsEnabled { self.updateKeyTitles() }
    }
    
    @objc func backspaceTimerFired(timer: Timer) {
        if (self.backspaceCount < 15) {
            self.textDocumentProxy.deleteBackward()
            self.backspaceCount += 1
        } else {
            self.textDocumentProxy.deleteBackward()
            if let words = self.textDocumentProxy.documentContextBeforeInput?.components(separatedBy: " ") {
                let charsToDelete = words.last!.count + 1
                for _ in 1...charsToDelete { self.textDocumentProxy.deleteBackward() }
            }
            if self.textDocumentProxy.documentContextBeforeInput?.count == 0 { self.stopBackspace() }
        }
    }
    
    //
    //  Space
    //
    
    func startSpaceTimer() {
        self.spaceTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(spaceTimerFired(timer:)), userInfo: nil, repeats: false)
    }
    
    @objc func spaceTimerFired(timer: Timer) {
        self.spaceTimer.invalidate()
    }
    
    //
    //  Suggestions
    //
    
    func layoutSuggestions() {
        let buttonWidth = self.suggestionsViewWidth / 3
        suggestionButtons[0].setLayout(x: self.suggestionsViewX + self.suggestionsViewWidth - buttonWidth,
                                       y: self.suggestionsViewY,
                                       width: buttonWidth,
                                       height: self.suggestionsViewHeight,
                                       marginTop: self.suggestionsMarginTop,
                                       marginLeft: 0,
                                       marginRight: self.suggestionsMarginSide)
        suggestionButtons[1].setLayout(x: self.suggestionsViewX + buttonWidth,
                                       y: self.suggestionsViewY,
                                       width: buttonWidth,
                                       height: self.suggestionsViewHeight,
                                       marginTop: self.suggestionsMarginTop,
                                       marginLeft: 0,
                                       marginRight: 0)
        suggestionButtons[2].setLayout(x: self.suggestionsViewX,
                                       y: self.suggestionsViewY,
                                       width: buttonWidth,
                                       height: self.suggestionsViewHeight,
                                       marginTop: self.suggestionsMarginTop,
                                       marginLeft: self.suggestionsMarginSide,
                                       marginRight: 0)
        self.layoutSuggestionDividers()
    }
    
    func layoutSuggestionDividers() {
        let leftButton = suggestionButtons[2]
        let rightButton = suggestionButtons[0]
        
        let leftDividerRect = CGRect(x: leftButton.frame.maxX,
                                     y: leftButton.frame.minY + CGFloat(self.suggestionsMarginTop) + 8,
                                     width: 1,
                                     height: leftButton.frame.height - CGFloat(self.suggestionsMarginTop) - 16)
        let rightDividerRect = CGRect(x: rightButton.frame.minX,
                                      y: rightButton.frame.minY + CGFloat(self.suggestionsMarginTop) + 8,
                                      width: 1,
                                      height: rightButton.frame.height - CGFloat(self.suggestionsMarginTop) - 16)
        
        let leftDividerPath = UIBezierPath(rect: leftDividerRect)
        let rightDividerPath = UIBezierPath(rect: rightDividerRect)
        
        self.leftDividerLayer.path = leftDividerPath.cgPath
        self.rightDividerLayer.path = rightDividerPath.cgPath
        self.setSuggestionDividerColors()
        self.updateSuggestionDividerVisibility()
    }
    
    func setSuggestionDividerColors() {
        if self.colorMode == KeyboardColorMode.Light {
            self.leftDividerLayer.fillColor = Colors.lightModeSuggestionDivider.cgColor
            self.rightDividerLayer.fillColor = Colors.lightModeSuggestionDivider.cgColor
        } else {
            self.leftDividerLayer.fillColor = Colors.darkModeSuggestionDivider.cgColor
            self.rightDividerLayer.fillColor = Colors.darkModeSuggestionDivider.cgColor
        }
    }
    
    func showLeftDivider() {
        if !self.leftDividerVisible {
            self.suggestionsView.layer.addSublayer(self.leftDividerLayer)
            self.leftDividerVisible = true
        }
    }
    
    func hideLeftDivider() {
        if self.leftDividerVisible {
            self.leftDividerLayer.removeFromSuperlayer()
            self.leftDividerVisible = false
        }
    }
    
    func showRightDivider() {
        if !self.rightDividerVisible {
            self.suggestionsView.layer.addSublayer(self.rightDividerLayer)
            self.rightDividerVisible = true
        }
    }
    
    func hideRightDivider() {
        if self.rightDividerVisible {
            self.rightDividerLayer.removeFromSuperlayer()
            self.rightDividerVisible = false
        }
    }
    
    func updateSuggestionDividerVisibility() {
        if suggestionButtons[0].highlightVisible || suggestionButtons[1].highlightVisible { self.hideRightDivider() }
        else { self.showRightDivider() }
        if suggestionButtons[1].highlightVisible || suggestionButtons[2].highlightVisible { self.hideLeftDivider() }
        else { self.showLeftDivider() }
    }
    
    func setUpSuggestionButtons() {
        for _ in 1...3 {
            let button = SuggestionButton()
            self.suggestionsView.addSubview(button)
            self.suggestionButtons.append(button)
            button.addTarget(self, action: #selector(suggestionTouchUp(sender:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(suggestionTouchDown(sender:)), for: .touchDown)
            button.addTarget(self, action: #selector(suggestionDragExit(sender:)), for: .touchDragExit)
        }
    }
    
    func resetSuggestions() {
        for button in suggestionButtons {
            button.reset()
        }
        self.updateSuggestionDividerVisibility()
    }
    
    func updateSuggestions() {
        let word = self.currentWord()
        var points: [CGPoint]?
        if self.touchPoints.count >= word.count {
            points = Array.init(self.touchPoints.suffix(word.count))
        }
        let suggestions = self.autoCorrect.getSuggestions(word: word, keys: letterKeys, touchPoints: points)
        resetSuggestions()
        for i in 0..<suggestions.count {
            suggestionButtons[i].setSuggestion(suggestions[i])
        }
        self.updateSuggestionDividerVisibility()
    }
    
    @objc func suggestionTouchUp(sender: SuggestionButton) {
        if (sender.suggestion != nil) {
            self.deleteCurrentWord()
            self.textDocumentProxy.insertText(sender.suggestion!.text + " ")
            self.updateKeyTitles()
            self.resetSuggestions()
        }
    }
    
    @objc func suggestionTouchDown(sender: SuggestionButton) {
        for button in suggestionButtons {
            if button == sender { button.showHighlight() }
            else { button.hideHighlight() }
        }
        self.updateSuggestionDividerVisibility()
    }
    
    @objc func suggestionDragExit(sender: SuggestionButton) {
        sender.hideHighlight()
        self.updateSuggestionDividerVisibility()
    }
    
    //
    //  Settings
    //
    
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
    
    //
    //  Deal with Text Document Proxy
    //
    
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
        if self.textDocumentProxy.documentContextBeforeInput == nil { return "" }
        var text = self.textDocumentProxy.documentContextBeforeInput!
        if text.count == 0 { return "" }
        if ArabicScript.removeDiacritics(String(text.last!)) == " " { return "" }
        if text.last?.unicodeScalars.last?.value == 0x200C { return "" }
        if NSCharacterSet.punctuationCharacters.contains(text.last!.unicodeScalars.last!) { return "" }
        if text.last == tatweel { text.removeLast() }
        var word = ""
        let reversed = String(text.reversed())
        for char in reversed {
            let cleanedChar = ArabicScript.removeDiacritics(String(char))
            if cleanedChar.count == 0 { break }
            if cleanedChar == " " { break }
            if cleanedChar.unicodeScalars.last?.value == 0x200C { break }
            if NSCharacterSet.punctuationCharacters.contains(cleanedChar.unicodeScalars.last!) { break }
            word += String(char)
        }
        return String(word.reversed())
    }
    
    func deleteCurrentWord() {
        while self.inWord() {
            self.textDocumentProxy.deleteBackward()
        }
    }
    
    func deleteTatweelIfNeeded() {
        if self.contextualFormsEnabled {
            if self.textDocumentProxy.documentContextBeforeInput?.last == tatweel {
                self.textDocumentProxy.deleteBackward()
            }
        }
    }
    
    func inWord() -> Bool {
        if self.lastCharacter() == nil { return false }
        if self.followingSpace() { return false }
        if self.followingZeroWidthNonJoiner() { return false }
        if self.followingPunctuation() { return false }
        return true
    }
    
    func followingSpace() -> Bool {
        return self.lastCharacter() == " "
    }
    
    func followingZeroWidthNonJoiner() -> Bool {
        let lastScalar = lastCharacter()?.unicodeScalars.last
        return lastScalar?.value == 0x200C
    }
    
    func followingPunctuation() -> Bool {
        if self.lastCharacter() == nil {
            return false
        }
        else {
            var s = String()
            s.append(self.lastCharacter()!)
            return s.rangeOfCharacter(from: NSCharacterSet.punctuationCharacters) != nil
        }
    }
    
    func mergeHamzaForward(currentChar: String) {
        if self.inWord() && self.lastCharacter() == "ء" {
            self.textDocumentProxy.deleteBackward()
            self.textDocumentProxy.insertText("ئ")
        }
    }
    
    func insertDefaultSuggestedWord() {
        for button in suggestionButtons {
            if button.suggestion != nil {
                if button.suggestion!.isDefault {
                    self.deleteCurrentWord()
                    self.textDocumentProxy.insertText(button.suggestion!.text)
                }
            }
        }
    }
    
    //
    //  Device Information
    //
    
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
        case "iPhone10,3", "iPhone10,6", "iPhone11,2":
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
    
    func getCurrentOrientation() -> Orientation {
        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
            return Orientation.portrait
        } else {
            return Orientation.landscape
        }
    }
    
}
