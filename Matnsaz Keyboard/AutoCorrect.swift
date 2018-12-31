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
    
    init() {
        // read wordFrequency file into memory
        let fileName = "WordFrequency"
        let path = Bundle.main.path(forResource: fileName, ofType: "")
        let inputStream = InputStream.init(fileAtPath: path!)
        inputStream?.open()
        wordFrequency =  try! JSONSerialization.jsonObject(with: inputStream!, options: []) as! [String : Int]
        inputStream?.close()
    }
    
    func getSuggestions(word: String, keys: [String: Key]) -> [String] {
        
        // get possible letter combinations
        var possibleLetterCombinations : [String] = []
        var i = word.startIndex
        while i < word.endIndex {
            let c = String(word[i])
            let neighbors = keys[c]!.neighbors
            for letter in neighbors! {
                var combo = word
                combo.replaceSubrange(i..<word.index(after: i), with: letter)
                possibleLetterCombinations.append(combo)
            }
            i = word.index(after: i)
        }
        
        // get word frequencies for each possible combination
        var freqs : [String: Int] = [:]
        for combo in possibleLetterCombinations {
            if wordFrequency[combo] != nil {
                freqs[combo] = wordFrequency[combo]
            }
        }
        
        var result : [String] = []
        while freqs.count > 0 {
            let mostCommonWord = freqs.max{ a, b in a.value < b.value }!.key
            freqs.removeValue(forKey: mostCommonWord)
            result.append(mostCommonWord)
        }
        
        return result
    }
    
}
