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
    
    func substringWithRange(range: NSRange) -> String {
        let rangeStart : String.Index = self.startIndex.advancedBy(range.location)
		let rangeEnd = rangeStart.advancedBy(range.length)
        return self.substringWithRange(rangeStart..<rangeEnd)
    }
}


extension NSTextCheckingResult {
	func groupsInString(string: String) -> [String?] {
		return (0..<self.numberOfRanges).map {
			let range = self.rangeAtIndex($0)
			return (range.location != NSNotFound) ? string.substringWithRange(range) : nil
		}
	}
}

struct Regex {
	let pattern: String
	let options: NSRegularExpressionOptions
	let matcher: NSRegularExpression!
	
	init(pattern: String, options: NSRegularExpressionOptions = []) throws {
		self.pattern = pattern
		self.options = options
		self.matcher = try NSRegularExpression(pattern: self.pattern, options: self.options)
	}
	
	func match(string: String, options: NSMatchingOptions = []) -> Bool {
		return self.matcher.numberOfMatchesInString(string, options: options, range: string.range) != 0
	}
	
	func matchingsOf(string: String, options: NSMatchingOptions = []) -> [String] {
		var matches : [String] = []
		self.matcher.enumerateMatchesInString(string, options: options, range: string.range) {
			(result: NSTextCheckingResult?, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
			if let result = result {
				matches.append(string.substringWithRange(result.range))
			}
		}
		return matches
	}
	
	func matchingGroupsOf(string: String, options: NSMatchingOptions = []) -> [[String?]] {
		var matches : [[String?]] = []
		self.matcher.enumerateMatchesInString(string, options: options, range: string.range) {
			(result: NSTextCheckingResult?, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
			if let result = result {
				matches.append(result.groupsInString(string))
			}
		}
		return matches
	}
	
	func groupsOfFirstMatch(string: String, options: NSMatchingOptions = []) -> [String?] {
		if let match = self.matcher.firstMatchInString(string, options: options, range: string.range) {
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

extension Regex: StringLiteralConvertible {
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
