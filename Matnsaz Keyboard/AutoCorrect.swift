//
//  AutoCorrect.swift
//  Matnsaz Keyboard
//
//  Created by Zeerak Ahmed on 12/30/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import Foundation

class AutoCorrect {
    
    var wordFrequency : [String:Int]
    var auralNeighbours = [
        "ا": ["ع"],
        "ت": ["ط"],
        "ث": ["س", "ص"],
        "ح": ["ہ", "ھ"],
        "ذ": ["ز", "ض", "ظ"],
        "ز": ["ذ", "ض", "ظ"],
        "س": ["ث", "ص"],
        "ص": ["ث", "س"],
        "ض": ["ذ", "ز", "ظ"],
        "ط": ["ت"],
        "ظ": ["ذ", "ز", "ض"],
        "ع": ["ا"],
        "ق": ["ک"],
        "ک": ["ق"],
        "ہ": ["ح", "ھ"],
        "ھ": ["ح", "ہ"],
        ]
    
    
    init() {
        // read wordFrequency file into memory
        let fileName = "WordFrequency"
        let path = Bundle.main.path(forResource: fileName, ofType: "")
        let inputStream = InputStream.init(fileAtPath: path!)
        inputStream?.open()
        wordFrequency =  try! JSONSerialization.jsonObject(with: inputStream!, options: []) as! [String : Int]
        inputStream?.close()
    }
    
    func getSuggestions(word: String, keys: [String: Key]) -> [Suggestion] {
        
        var result : [Suggestion] = []
        
        if word == "" {
            return result
        }
        
        var matches : [String:Int] = [:]
        let cleanedWord = ArabicScript.removeDiacritics(word)
        
        // go through ever item in dictionary
        for item in wordFrequency {
            
            // ignore if length is different
            if item.key.count != cleanedWord.count { continue }
            
            // add to matches if each character is one in the typed sequence or its neighbors
            var i = cleanedWord.startIndex
            var match = true
            
            while i < cleanedWord.endIndex {
                var c = String(cleanedWord[i])
                if ["ئ","ؤ","أ"].contains(c) {
                    c = "ء"
                }
                let d = String(item.key[i])
                if d != c && !keys[c]!.neighbors!.contains(d)  {
                    match = false
                }
                i = cleanedWord.index(after: i)
            }
            
            if match {
                matches[item.key] = item.value
            }
        }
        
        // append word as is for first suggestion
        result.append(Suggestion.init(text: word,
                                      isDefault: true,
                                      isUserTypedString: true))
        
        // add two more words, checking for duplicates
        while matches.count > 0 && result.count <= 3 {
            let mostCommonWord = matches.max{ a, b in a.value < b.value }!.key
            matches.removeValue(forKey: mostCommonWord)
            if mostCommonWord != cleanedWord {
                result.append(Suggestion.init(text: mostCommonWord,
                                              isDefault: false,
                                              isUserTypedString: false))
            }
        }
        
        // change default if sure
        if wordFrequency[cleanedWord] == nil && wordFrequency[word] == nil && result.count > 1 {
            result[0].isDefault = false
            result[1].isDefault = true
        }
        
        return Array<Suggestion>(result.prefix(3))
    }
    
}
