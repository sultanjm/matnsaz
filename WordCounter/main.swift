//
//  main.swift
//  WordCounter
//
//  Created by Zeerak Ahmed on 12/30/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import Foundation

// file for WordFrequency model
var filePath = "../Matnsaz Keyboard/Language Models/WordFrequency"

// dictionary for count
var wordCount : [String:Int] = [:]

// read existing dictionary
let inputStream = InputStream.init(fileAtPath: filePath)
inputStream?.open()
wordCount =  try! JSONSerialization.jsonObject(with: inputStream!, options: []) as! [String : Int]
inputStream?.close()

// read file
var text = ""
while let line = readLine() {
    text += line
}
text = ArabicScript.removeDiacritics(text)

var word = ""
var words = 0

// go through each character
for char in text {
    
    // add to word if letter
    if ArabicScript.isLetter(char) {
        word += String(char)
    }
    
    // add to dictionary if end of letter
    else if char == " " {
        if wordCount.index(forKey: word) == nil {
            wordCount[word] = 1
        } else {
            let count = wordCount[word]!
            wordCount.updateValue(count + 1, forKey: word)
        }
        word = ""
        words += 1
    }
    
    else {
        continue
    }
}

// write to file
var outputStream = OutputStream.init(toFileAtPath: filePath, append: false)
outputStream?.open()
JSONSerialization.writeJSONObject(wordCount, to: outputStream!, options: [], error: nil)
outputStream?.close()

print(words)

