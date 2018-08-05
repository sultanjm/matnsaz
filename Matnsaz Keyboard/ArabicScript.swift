//
//  File.swift
//  Z 0.1
//
//  Created by Zeerak Ahmed on 3/27/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import Foundation

class ArabicScript {
    
    enum CharacterVariant {
        case Isolated
        case Initial
        case Medial
        case Final
    }
    
    class func getCharacterVariant(_ char: Character, variant: CharacterVariant) -> String {
        switch char {
        case "ا":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "ا"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﺎ"
            }
        case "ب":
            switch variant {
            case CharacterVariant.Isolated:
                return "ﺏ"
            case CharacterVariant.Initial:
                return "ﺑ"
            case CharacterVariant.Medial:
                return "ﺒ"
            case CharacterVariant.Final:
                return "ﺐ"
            }
        case "پ":
            switch variant {
            case CharacterVariant.Isolated:
                return "پ"
            case CharacterVariant.Initial:
                return "ﭘ"
            case CharacterVariant.Medial:
                return "ﭙ"
            case CharacterVariant.Final:
                return "ﭗ"
            }
        case "ت":
            switch variant {
            case CharacterVariant.Isolated:
                return "ت"
            case CharacterVariant.Initial:
                return "ﺗ"
            case CharacterVariant.Medial:
                return "ﺘ"
            case CharacterVariant.Final:
                return "ﺖ"
            }
        case "ٹ":
            switch variant {
            case CharacterVariant.Isolated:
                return "ٹ"
            case CharacterVariant.Initial:
                return "ﭨ"
            case CharacterVariant.Medial:
                return "ﭩ"
            case CharacterVariant.Final:
                return "ﭧ"
            }
        case "ث":
            switch variant {
            case CharacterVariant.Isolated:
                return "ث"
            case CharacterVariant.Initial:
                return "ﺛ"
            case CharacterVariant.Medial:
                return "ﺜ"
            case CharacterVariant.Final:
                return "ﺚ"
            }
        case "ج":
            switch variant {
            case CharacterVariant.Isolated:
                return "ج"
            case CharacterVariant.Initial:
                return "ﺟ"
            case CharacterVariant.Medial:
                return "ﺠ"
            case CharacterVariant.Final:
                return "ﺞ"
            }
        case "چ":
            switch variant {
            case CharacterVariant.Isolated:
                return "چ"
            case CharacterVariant.Initial:
                return "ﭼ"
            case CharacterVariant.Medial:
                return "ﭽ"
            case CharacterVariant.Final:
                return "ﭻ"
            }
        case "ح":
            switch variant {
            case CharacterVariant.Isolated:
                return "ح"
            case CharacterVariant.Initial:
                return "ﺣ"
            case CharacterVariant.Medial:
                return "ﺤ"
            case CharacterVariant.Final:
                return "ﺢ"
            }
        case "خ":
            switch variant {
            case CharacterVariant.Isolated:
                return "خ"
            case CharacterVariant.Initial:
                return "ﺧ"
            case CharacterVariant.Medial:
                return "ﺨ"
            case CharacterVariant.Final:
                return "ﺦ"
            }
        case "د":
            switch variant {
            case CharacterVariant.Isolated:
                return "د"
            case CharacterVariant.Initial:
                return "د"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﺪ"
            }
        case "ڈ":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "ڈ"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﮉ"
            }
        case "ذ":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "ذ"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﺬ"
            }
        case "ر":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "ر"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﺮ"
            }
        case "ڑ":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "ڑ"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﮍ"
            }
        case "ز":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "ز"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﺰ"
            }
        case "ژ":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "ژ"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﮋ"
            }
        case "س":
            switch variant {
            case CharacterVariant.Isolated:
                return "س"
            case CharacterVariant.Initial:
                return "ﺳ"
            case CharacterVariant.Medial:
                return "ﺴ"
            case CharacterVariant.Final:
                return "ﺲ"
            }
        case "ش":
            switch variant {
            case CharacterVariant.Isolated:
                return "ش"
            case CharacterVariant.Initial:
                return "ﺷ"
            case CharacterVariant.Medial:
                return "ﺸ"
            case CharacterVariant.Final:
                return "ﺶ"
            }
        case "ص":
            switch variant {
            case CharacterVariant.Isolated:
                return "ص"
            case CharacterVariant.Initial:
                return "ﺻ"
            case CharacterVariant.Medial:
                return "ﺼ"
            case CharacterVariant.Final:
                return "ﺺ"
            }
        case "ض":
            switch variant {
            case CharacterVariant.Isolated:
                return "ض"
            case CharacterVariant.Initial:
                return "ﺿ"
            case CharacterVariant.Medial:
                return "ﻀ"
            case CharacterVariant.Final:
                return "ﺾ"
            }
        case "ط":
            switch variant {
            case CharacterVariant.Isolated:
                return "ط"
            case CharacterVariant.Initial:
                return "ﻃ"
            case CharacterVariant.Medial:
                return "ﻄ"
            case CharacterVariant.Final:
                return "ﻂ"
            }
        case "ظ":
            switch variant {
            case CharacterVariant.Isolated:
                return "ظ"
            case CharacterVariant.Initial:
                return "ﻇ"
            case CharacterVariant.Medial:
                return "ﻈ"
            case CharacterVariant.Final:
                return "ﻆ"
            }
        case "ع":
            switch variant {
            case CharacterVariant.Isolated:
                return "ع"
            case CharacterVariant.Initial:
                return "ﻋ"
            case CharacterVariant.Medial:
                return "ﻌ"
            case CharacterVariant.Final:
                return "ﻊ"
            }
        case "غ":
            switch variant {
            case CharacterVariant.Isolated:
                return "غ"
            case CharacterVariant.Initial:
                return "ﻏ"
            case CharacterVariant.Medial:
                return "ﻐ"
            case CharacterVariant.Final:
                return "ﻎ"
            }
        case "ف":
            switch variant {
            case CharacterVariant.Isolated:
                return "ف"
            case CharacterVariant.Initial:
                return "ﻓ"
            case CharacterVariant.Medial:
                return "ﻔ"
            case CharacterVariant.Final:
                return "ﻒ"
            }
        case "ق":
            switch variant {
            case CharacterVariant.Isolated:
                return "ق"
            case CharacterVariant.Initial:
                return "ﻗ"
            case CharacterVariant.Medial:
                return "ﻘ"
            case CharacterVariant.Final:
                return "ﻖ"
            }
        case "ک":
            switch variant {
            case CharacterVariant.Isolated:
                return "ک"
            case CharacterVariant.Initial:
                return "ﻛ"
            case CharacterVariant.Medial:
                return "ﮑ"
            case CharacterVariant.Final:
                return "ﮏ"
            }
        case "گ":
            switch variant {
            case CharacterVariant.Isolated:
                return "گ"
            case CharacterVariant.Initial:
                return "ﮔ"
            case CharacterVariant.Medial:
                return "ﮕ"
            case CharacterVariant.Final:
                return "ﮓ"
            }
        case "ل":
            switch variant {
            case CharacterVariant.Isolated:
                return "ل"
            case CharacterVariant.Initial:
                return "ﻟ"
            case CharacterVariant.Medial:
                return "ﻠ"
            case CharacterVariant.Final:
                return "ﻞ"
            }
        case "م":
            switch variant {
            case CharacterVariant.Isolated:
                return "م"
            case CharacterVariant.Initial:
                return "ﻣ"
            case CharacterVariant.Medial:
                return "ﻤ"
            case CharacterVariant.Final:
                return "ﻢ"
            }
        case "ن":
            switch variant {
            case CharacterVariant.Isolated:
                return "ن"
            case CharacterVariant.Initial:
                return "ﻧ"
            case CharacterVariant.Medial:
                return "ﻨ"
            case CharacterVariant.Final:
                return "ﻦ"
            }
        case "ں":
            switch variant {
            case CharacterVariant.Isolated:
                return "ں"
            case CharacterVariant.Initial:
                return "ﻧ٘"
            case CharacterVariant.Medial:
                return "ﻨ٘"
            case CharacterVariant.Final:
                return "ﮟ"
            }
        case "و":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "و"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﻮ"
            }
        case "ہ":
            switch variant {
            case CharacterVariant.Isolated:
                return "ہ"
            case CharacterVariant.Initial:
                return "ﮨ"
            case CharacterVariant.Medial:
                return "ﮩ"
            case CharacterVariant.Final:
                return "ﮧ"
            }
        case "ھ":
            switch variant {
            case CharacterVariant.Isolated:
                return "ھ"
            case CharacterVariant.Initial:
                return "ﮬ"
            case CharacterVariant.Medial:
                return "ﮭ"
            case CharacterVariant.Final:
                return "ﮫ"
            }
        case "ء":
            switch variant {
            case CharacterVariant.Isolated:
                return "ء"
            case CharacterVariant.Initial:
                return "ﺋ"
            case CharacterVariant.Medial:
                return "ﺌ"
            case CharacterVariant.Final:
                return "ء"
            }
        case "ی":
            switch variant {
            case CharacterVariant.Isolated:
                return "ی"
            case CharacterVariant.Initial:
                return "ﻳ"
            case CharacterVariant.Medial:
                return "ﻴ"
            case CharacterVariant.Final:
                return "ﯽ"
            }
        case "ے":
            switch variant {
            case CharacterVariant.Isolated,
                 CharacterVariant.Initial:
                return "ے"
            case CharacterVariant.Medial,
                 CharacterVariant.Final:
                return "ﮯ"
            }
        default:
            fatalError(String(format: "Unknown Character %s", String(char)))
        }
    }
    
    class func isForwardJoining(_ char: Character) -> Bool {
        return getCharacterVariant(char, variant: CharacterVariant.Initial) != getCharacterVariant(char, variant: CharacterVariant.Isolated)
    }
    
    class func isLetter(_ char: Character) -> Bool {
        switch char.unicodeScalars {
        default:
            return false
        }
    }
    
    // this assum
    class func addTatweelTo(_ string: String, toDisplay characterVariant: CharacterVariant) -> String {
        let tatweel = "ـ"
        var suffix = ""
        if self.isForwardJoining(string.last!) {
            suffix = tatweel
        }
        switch characterVariant {
        case CharacterVariant.Isolated:
            return string
        case CharacterVariant.Initial:
            return string + suffix
        case CharacterVariant.Medial:
            return tatweel + string + suffix
        case CharacterVariant.Final:
            return tatweel + string
        }
    }
    
    class func isUrduPreferredLanguage() -> Bool {
        let preferredLanguages = NSLocale.preferredLanguages
        for lang in preferredLanguages {
            if lang.contains("ur") {
                return true
            }
        }
        return false
    }
    
    class func isNastaliqEnabled() -> Bool {
        return isUrduPreferredLanguage()
    }
}
