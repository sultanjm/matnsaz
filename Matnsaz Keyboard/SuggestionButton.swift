//
//  SuggestionButton.swift
//  Matnsaz Keyboard
//
//  Created by Zeerak Ahmed on 12/31/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import UIKit

class SuggestionButton: UIButton {
    
    var suggestion = ""
    var label = UILabel()
    var isUserInputSuggestion: Bool = false
    
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = Colors.lightModeBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout(x: Double, y: Double, width: Double, height: Double) {
        
        // frame
        super.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // set up label
        self.label.font = UIFont.systemFont(ofSize: CGFloat(height * 0.3))
        self.label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.label.textAlignment = NSTextAlignment.center
        self.addSubview(self.label)
    
    }
    
    func setLabel(_ t: String) {
        var text = t
        if self.isUserInputSuggestion && t != "" {
            text = "\"" + text + "\""
        }
        self.label.text = text
    }
}
