//
// Inflector.swift
// Copyright (c) 2014 NGeen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class Inflector: NSObject {
    
    private var pluralRules: [InflectorRule]
    private var singularRules: [InflectorRule]
    private var words: NSMutableSet
    
    // MARK: Constructor
    
    override init() {
        self.pluralRules = Array()
        self.singularRules = Array()
        self.words = NSMutableSet()
        super.init()
        let path: String = NSBundle.mainBundle().pathForResource("Inflector", ofType: "plist")
        if !path.isEmpty {
            self.setRulesFromDictionary(NSDictionary(contentsOfFile: path))
        }
    }
    
    // MARK: Instance methods
    
    /**
    * The function return the pluralized string.
    *
    * @param string The string to pluralize.
    *
    * return String
    */
    
    func pluralize(string: String) -> String {
        return self.applyRules(self.pluralRules, forString: string)
    }
    
    /**
    * The function add a new irregular rule.
    *
    * @param singular The singular rule to apply.
    * @param plural The plural rule to apply.
    *
    */
    
    func setIrregularRuleForSingular(singular: String, andPlural plural: String) {
        let singularRule: String = "\(plural)$"
        self.setSingularRule(singularRule, forReplacement: singular)
        let pluralRule: String = "\(singular)$"
        self.setPluralRule(pluralRule, forReplacement: plural)
    }
    
    /**
    * The function add a new singular rule.
    *
    * @param rule The rule to apply.
    * @param replacement The value to replace the rule.
    *
    */
    
    func setSingularRule(rule: String, forReplacement replacement: String) {
        self.singularRules.append(InflectorRule(rule: rule, replacement: replacement))
    }
    
    /**
    * The function add a new plural rules.
    *
    * @param rule The rule to apply.
    * @param replacement The value to replace the rule.
    *
    */
    
    func setPluralRule(rule: String, forReplacement replacement: String) {
        self.pluralRules.append(InflectorRule(rule: rule, replacement: replacement))
    }
    
    /**
    * The function add the a new uncountable word
    *
    * @param word The uncountable word.
    *
    */
    
    func setUncountableWord(word: String) {
        self.words.addObject(word)
    }
    
    /**
    * The function add the rules for the inflection
    *
    * @param dictionary The dictionary with rules.
    *
    */
    
    func setRulesFromDictionary(dictionary: NSDictionary) {
        for value in dictionary["pluralRules"] as [[String]] {
            self.setPluralRule(value[0] as String, forReplacement: value[1] as String)
        }
        for value in dictionary["singularRules"] as [[String]] {
            self.setSingularRule(value[0] as String, forReplacement: value[1] as String)
        }
        for value in dictionary["irregularRules"] as [[String]] {
            self.setSingularRule(value[0] as String, forReplacement: value[1] as String)
        }
        
        for value in dictionary["uncountableWords"] as [String] {
            self.setUncountableWord(value)
        }
    }
    
    /**
    * The function return the singularized string.
    *
    * @param string The string to singularize
    .
    *
    * return String
    */
    
    func singularize(string: String) -> String {
        return self.applyRules(self.singularRules, forString: string)
    }
    
    // MARK: Private methods
    
    /**
    * The function apply the inflection rules to a given string
    *
    * @param rules The array with rules to apply.
    * @param string The string to apply the rules.
    *
    */
    
    private func applyRules(rules: [InflectorRule], forString string: String) -> String {
        if self.words.containsObject(string) {
            return string
        } else {
            for rule in rules {
                let range = NSMakeRange(0,  string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                let regex: NSRegularExpression = NSRegularExpression.regularExpressionWithPattern(rule.rule, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
                if regex.firstMatchInString(string, options: NSMatchingOptions.ReportProgress, range: range) {
                    return regex.stringByReplacingMatchesInString(string, options: NSMatchingOptions.ReportProgress, range: range, withTemplate: rule.replacement)
                }
            }
        }
        return string
    }
}
