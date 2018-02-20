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
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // custom view sizing constraints
        let expandedHeight:CGFloat = 280.0
        let heightConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0.0, constant: expandedHeight)
        self.view.addConstraint(heightConstraint)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        
        // add next keyboard button
        self.nextKeyboardButton = UIButton(type: .system)
        self.nextKeyboardButton.setTitle("🌐", for: [])
        self.nextKeyboardButton.setBackgroundImage(UIImage(named: "keycap"), for: UIControlState())
//        self.nextKeyboardButton.frame = CGRect(x: 5, y: 226, width: 32, height: 42)
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        self.view.addSubview(self.nextKeyboardButton)
        
        let guide = inputView!.layoutMarginsGuide
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false;
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8.0).isActive = true
        self.nextKeyboardButton.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        self.nextKeyboardButton.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        
        // add next keyboard button
        let button = UIButton(type: .system)
        button.setTitle("→", for: [])
        button.setBackgroundImage(UIImage(named: "keycap"), for: UIControlState())
        button.frame = CGRect(x: 5, y: 172, width: 32, height: 42)
        button.addTarget(self, action: #selector(backspace(sender:)), for: .allTouchEvents)
        self.view.addSubview(button)
        
        // add keys
        addButton(title: "ا", x: 339, y: 10, width: 32, height: 42)
        addButton(title: "ب", x: 301, y: 10, width: 32, height: 42)
        addButton(title: "پ", x: 264, y: 10, width: 32, height: 42)
        addButton(title: "ت", x: 227, y: 10, width: 32, height: 42)
        addButton(title: "ٹ", x: 190, y: 10, width: 32, height: 42)
        addButton(title: "ث", x: 153, y: 10, width: 32, height: 42)
        addButton(title: "ج", x: 116, y: 10, width: 32, height: 42)
        addButton(title: "چ", x: 79, y: 10, width: 32, height: 42)
        addButton(title: "ح", x: 42, y: 10, width: 32, height: 42)
        addButton(title: "خ", x: 5, y: 10, width: 32, height: 42)
        addButton(title: "د", x: 339, y: 64, width: 32, height: 42)
        addButton(title: "ڈ", x: 301, y: 64, width: 32, height: 42)
        addButton(title: "ذ", x: 264, y: 64, width: 32, height: 42)
        addButton(title: "ر", x: 227, y: 64, width: 32, height: 42)
        addButton(title: "ڑ", x: 190, y: 64, width: 32, height: 42)
        addButton(title: "ز", x: 153, y: 64, width: 32, height: 42)
        addButton(title: "ژ", x: 116, y: 64, width: 32, height: 42)
        addButton(title: "س", x: 79, y: 64, width: 32, height: 42)
        addButton(title: "ش", x: 42, y: 64, width: 32, height: 42)
        addButton(title: "ص", x: 5, y: 64, width: 32, height: 42)
        addButton(title: "ض", x: 339, y: 118, width: 32, height: 42)
        addButton(title: "ط", x: 301, y: 118, width: 32, height: 42)
        addButton(title: "ظ", x: 264, y: 118, width: 32, height: 42)
        addButton(title: "ع", x: 227, y: 118, width: 32, height: 42)
        addButton(title: "غ", x: 190, y: 118, width: 32, height: 42)
        addButton(title: "ف", x: 153, y: 118, width: 32, height: 42)
        addButton(title: "ق", x: 116, y: 118, width: 32, height: 42)
        addButton(title: "ک", x: 79, y: 118, width: 32, height: 42)
        addButton(title: "گ", x: 42, y: 118, width: 32, height: 42)
        addButton(title: "ل", x: 5, y: 118, width: 32, height: 42)
        addButton(title: "م", x: 339, y: 172, width: 32, height: 42)
        addButton(title: "ن", x: 301, y: 172, width: 32, height: 42)
        addButton(title: "ں", x: 264, y: 172, width: 32, height: 42)
        addButton(title: "و", x: 227, y: 172, width: 32, height: 42)
        addButton(title: "ه", x: 190, y: 172, width: 32, height: 42)
        addButton(title: "ھ", x: 153, y: 172, width: 32, height: 42)
        addButton(title: "ء", x: 116, y: 172, width: 32, height: 42)
        addButton(title: "ی", x: 79, y: 172, width: 32, height: 42)
        addButton(title: "ے", x: 42, y: 172, width: 32, height: 42)
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
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    func addButton(title: String, x: Int, y: Int, width: Int, height: Int) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: [])
        button.addTarget(self, action: #selector(keyPressed(sender:)), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "keycap"), for: UIControlState())
        button.frame = CGRect(x: x, y: y, width: width, height: height)
        button.setTitleColor(UIColor.black, for:UIControlState())
        self.view.addSubview(button)
    }
    
    @objc func backspace(sender: UIButton) {
        self.textDocumentProxy.deleteBackward()
    }
    
    @objc func keyPressed(sender: UIButton) {
        let title = sender.title(for: UIControlState.normal)
        self.textDocumentProxy.insertText(title!)
    }

}
