//
//  AutoCorrect.swift
//  Matnsaz Keyboard
//
//  Created by Zeerak Ahmed on 12/30/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import Foundation
import UIKit

class AutoCorrect {
    
    var wordFrequency : [String:Double]
    var auralNeighbors = [
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
    
    enum CharacterMatchType {
        case NoMatch
        case ExactMatch
        case PhysicalNeighbor
        case AuralNeighbor
        case AuralNeighborOfPhysicalNeighbor
    }
    
    struct WordMatch {
        var rawString: String
        var cleanedString: String
        var score: Double
        var characterMatchTypes: [CharacterMatchType]
    }
    
    init() {
        // read wordFrequency file into memory
        let fileName = "WordFrequency"
        let path = Bundle.main.path(forResource: fileName, ofType: "")
        let inputStream = InputStream.init(fileAtPath: path!)
        inputStream?.open()
        wordFrequency =  try! JSONSerialization.jsonObject(with: inputStream!, options: []) as! [String : Double]
        inputStream?.close()
    }
    
    func getSuggestions(word: String, keys: [String: Key], touchPoints: [CGPoint]?) -> [Suggestion] {
        
        var result: [Suggestion] = []
        var matches: [WordMatch] = []
        
        var cleanedWord = ArabicScript.removeDiacritics(word)
        cleanedWord = cleanedWord.replacingOccurrences(of: "ئ", with: "ء")
        if cleanedWord == "" {
            return result
        }
        
        for entry in wordFrequency {

            // create match object
            var match = WordMatch(rawString: entry.key,
                                  cleanedString: ArabicScript.removeDiacritics(entry.key).replacingOccurrences(of: "ئ", with: "ء"),
                                  score: entry.value,
                                  characterMatchTypes: [])
            
            // ignore if lengths don't match
            if match.cleanedString.count != cleanedWord.count { continue }
            
            var i = cleanedWord.startIndex
            var j = 0
            var isMatch = true
            var nudgeDistance = 0.0
            
            // for each character
            while i < cleanedWord.endIndex {
                
                let c = String(cleanedWord[i])
                let d = String(match.cleanedString[i])
                
                var charMatch = CharacterMatchType.NoMatch
                
                // create potential match sets
                var physicalNeighbors: [String] = []
                var auralNeighbors: [String] = []
                var auralNeighborsOfPhysicalNeighbors: [String] = []
                
                if keys[c]?.neighbors != nil {
                    physicalNeighbors.append(contentsOf: keys[c]!.neighbors!)
                }
                if self.auralNeighbors[c] != nil {
                    auralNeighbors.append(contentsOf: self.auralNeighbors[c]!)
                }
                for n in physicalNeighbors {
                    if self.auralNeighbors[n] != nil {
                        auralNeighborsOfPhysicalNeighbors.append(contentsOf: self.auralNeighbors[n]!)
                    }
                }
                
                // identify type of match
                if d == c {
                    charMatch = CharacterMatchType.ExactMatch
                } else if physicalNeighbors.contains(d) {
                    charMatch = CharacterMatchType.PhysicalNeighbor
                } else if auralNeighbors.contains(d) {
                    charMatch = CharacterMatchType.AuralNeighbor
                } else if auralNeighborsOfPhysicalNeighbors.contains(d) {
                    charMatch = CharacterMatchType.AuralNeighborOfPhysicalNeighbor
                }
                
                // save or ignore match
                if charMatch == CharacterMatchType.NoMatch {
                    isMatch = false
                    break
                } else {
                    match.characterMatchTypes.append(charMatch)
                }
                
                // calculate distances
                if touchPoints != nil {
                    switch match.characterMatchTypes.last! {
                    case CharacterMatchType.ExactMatch,
                         CharacterMatchType.PhysicalNeighbor:
                        let keyLocation = keys[d]?.center
                        nudgeDistance += distance(from: touchPoints![j], to: keyLocation!)
                    case CharacterMatchType.AuralNeighbor:
                        let keyLocation = keys[c]?.center
                        nudgeDistance += distance(from: touchPoints![j], to: keyLocation!)
                    case CharacterMatchType.AuralNeighborOfPhysicalNeighbor:
                        // find which neighbor
                        var s: String?
                        for p in physicalNeighbors {
                            if self.auralNeighbors[p]?.contains(d) ?? false {
                                s = p
                                break
                            }
                        }
                        let keyLocation = keys[s!]?.center
                        nudgeDistance += distance(from: touchPoints![j], to: keyLocation!)
                    default:
                        break
                    }
                }
                
                i = cleanedWord.index(after: i)
                j += 1
            }
            
            if isMatch {
                match.score /= nudgeDistance * 2
                matches.append(match)
            }
            
        }
        
        // append word as is for first suggestion
        result.append(Suggestion.init(text: word,
                                      isDefault: true,
                                      isUserTypedString: true))
        
        // add two more words, checking for duplicates
        while matches.count > 0 && result.count <= 3 {
            let topMatch = matches.max{ a, b in a.score < b.score }!
            let topWord = topMatch.rawString
            matches.removeAll(where: { $0.rawString == topWord })
            if topWord != cleanedWord {
                result.append(Suggestion.init(text: topWord,
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
    
    func distance(from: CGPoint?, to: CGPoint?) -> Double {
        if from == nil || to == nil { return Double.greatestFiniteMagnitude }
        let x = pow(Double(from!.x - to!.x), 2)
        let y = pow(Double(from!.y - to!.y), 2)
        return sqrt(x + y)
    }
    
}
