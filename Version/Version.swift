//
//  Version.swift
//  Version
//
//  Created by Marius Rackwitz on 07/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Foundation


public class Version : Equatable, Comparable {
    public let major: Int
    public let minor: Int?
    public let patch: Int?
    public let prerelease: String?
    public let build: String?
    
    public required init(major: Int = 0, minor: Int? = nil, patch: Int? = nil, prerelease: String? = nil, build: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
    }
    
    public required init(_ value: String) {
        let parts = pattern.groupsOfFirstMatch(value)
        
        let majorStr = parts[1]
        let minorStr = parts.try(2)
        let patchStr = parts.try(3)
        
        self.major      = majorStr.toInt()!
        self.minor      = minorStr != nil ? minorStr!.toInt() : nil
        self.patch      = patchStr != nil ? patchStr!.toInt() : nil
        self.prerelease = parts.try(4)
        self.build      = parts.try(5)
    }
}


public func ==(lhs: Version, rhs: Version) -> Bool {
    return lhs.major == rhs.major
        && lhs.minor == rhs.minor
        && lhs.patch == rhs.patch
        && lhs.prerelease == rhs.prerelease
        && lhs.build == rhs.build
}


public func <(lhs: Version, rhs: Version) -> Bool {
    return lhs.major < rhs.major
        || lhs.minor < rhs.minor
        || lhs.patch < rhs.patch
        || lhs.prerelease < rhs.prerelease
        || lhs.build < rhs.build
}


extension Version : Printable {
    public var description: String {
        return "".join([
            "\(major)",
            minor      != nil ? ".\(minor!)"      : "",
            patch      != nil ? ".\(patch!)"      : "",
            prerelease != nil ? "-\(prerelease!)" : "",
            build      != nil ? "+\(build!)"      : ""
        ])
    }
}

let pattern = Regex(pattern: "([0-9]+)(?:\\.([0-9]+))?(?:\\.([0-9]+))?(?:-([0-9A-Za-z-]+))?(?:\\+([0-9A-Za-z-]+))?")
let anchoredPattern = Regex(pattern: "/\\A\\s*(\(pattern.pattern))?\\s*\\z/")

extension Version {
    public class func valid(string: String) -> Bool {
        return anchoredPattern.match(string)
    }
}


extension Version: StringLiteralConvertible {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public class func convertFromExtendedGraphemeClusterLiteral(value: ExtendedGraphemeClusterLiteralType) -> Self {
        return self(major: value.toInt()!)
    }
    
    public class func convertFromStringLiteral(value: StringLiteralType) -> Self {
        return self(value)
    }
}
