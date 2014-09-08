//
//  Regex.swift
//  Version
//
//  Based on: http://nshipster.com/swift-operators/
//  Created by Mattt Thompson.
//

import Foundation


extension String {
    func substringWithRange(range: NSRange) -> String {
        let rangeStart : String.Index = advance(self.startIndex, range.location)
        return self.substringWithRange(rangeStart..<advance(rangeStart, range.length))
    }
}


struct Regex {
    let pattern: String
    let options: NSRegularExpressionOptions!
    
    private var matcher: NSRegularExpression {
        var error : NSError?
        let regex = NSRegularExpression(pattern: self.pattern, options: self.options, error: &error)
        return regex
    }
    
    init(pattern: String, options: NSRegularExpressionOptions = nil) {
        self.pattern = pattern
        self.options = options
    }
    
    func match(string: String, options: NSMatchingOptions = nil) -> Bool {
        return self.matcher.numberOfMatchesInString(string, options: options, range: NSMakeRange(0, string.utf16Count)) != 0
    }
    
    func matchingsOf(string: String, options: NSMatchingOptions = nil) -> [String] {
        var matches : [String] = []
        self.matcher.enumerateMatchesInString(string, options: options, range: NSMakeRange(0, string.utf16Count)) {
            (result: NSTextCheckingResult!, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
            matches.append(string.substringWithRange(result.range))
        }
        return matches
    }
    
    func groupsOfFirstMatch(string: String, options: NSMatchingOptions = nil) -> [String] {
        var match = self.matcher.firstMatchInString(string, options: options, range: NSMakeRange(0, string.utf16Count))
        var groups : [String] = []
        if let match = match {
            for i in 0..<match.numberOfRanges {
                let range = match.rangeAtIndex(i)
                if range.location != NSNotFound {
                    groups.append(string.substringWithRange(range))
                }
            }
        }
        return groups
    }
}

func ==(lhs: Regex, rhs: Regex) -> Bool {
    return lhs.pattern == rhs.pattern
        && lhs.options == rhs.options
}

extension Regex: StringLiteralConvertible {
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    static func convertFromExtendedGraphemeClusterLiteral(value: ExtendedGraphemeClusterLiteralType) -> Regex {
        return self(pattern: value)
    }
    
    static func convertFromStringLiteral(value: StringLiteralType) -> Regex {
        return self(pattern: value)
    }
}
