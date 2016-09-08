//
//  Regex.swift
//  Version
//
//  Based on: http://nshipster.com/swift-operators/
//  Created by Mattt Thompson.
//

import Foundation


extension String {
    var range: NSRange {
        return NSMakeRange(0, self.utf16.count)
    }
    
    func substringWithRange(_ range: NSRange) -> String {
        let rangeStart : String.Index = self.characters.index(self.startIndex, offsetBy: range.location)
        let rangeEnd = self.characters.index(rangeStart, offsetBy: range.length)
        return self.substring(with: rangeStart..<rangeEnd)
    }
}


extension NSTextCheckingResult {
    func groupsInString(_ string: String) -> [String?] {
        return (0..<self.numberOfRanges).map {
            let range = self.rangeAt($0)
            return (range.location != NSNotFound) ? string.substringWithRange(range) : nil
        }
    }
}

struct Regex {
    let pattern: String
    let options: NSRegularExpression.Options
    let matcher: NSRegularExpression!
    
    init(pattern: String, options: NSRegularExpression.Options = []) throws {
        self.pattern = pattern
        self.options = options
        self.matcher = try NSRegularExpression(pattern: self.pattern, options: self.options)
    }
    
    func match(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        return self.matcher.numberOfMatches(in: string, options: options, range: string.range) != 0
    }
    
    func matchingsOf(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> [String] {
        var matches : [String] = []
        self.matcher.enumerateMatches(in: string, options: options, range: string.range) {
            (result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
            if let result = result {
                matches.append(string.substringWithRange(result.range))
            }
        }
        return matches
    }
    
    func matchingGroupsOf(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> [[String?]] {
        var matches : [[String?]] = []
        self.matcher.enumerateMatches(in: string, options: options, range: string.range) {
            (result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
            if let result = result {
                matches.append(result.groupsInString(string))
            }
        }
        return matches
    }
    
    func groupsOfFirstMatch(_ string: String, options: NSRegularExpression.MatchingOptions = []) -> [String?] {
        if let match = self.matcher.firstMatch(in: string, options: options, range: string.range) {
            return match.groupsInString(string)
        } else {
            return []
        }
    }
}

func ==(lhs: Regex, rhs: Regex) -> Bool {
    return lhs.pattern == rhs.pattern
        && lhs.options == rhs.options
}

extension Regex: ExpressibleByStringLiteral {
    typealias UnicodeScalarLiteralType = StringLiteralType
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    init(stringLiteral value: StringLiteralType) {
        try! self.init(pattern: value)
    }
}
