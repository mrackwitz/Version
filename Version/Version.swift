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
    public let buildMetadata: String?
    
    required public init(major: Int = 0, minor: Int? = nil, patch: Int? = nil, prerelease: String? = nil, buildMetadata: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.buildMetadata = buildMetadata
    }
}


public func ==(lhs: Version, rhs: Version) -> Bool {
    return lhs.major == rhs.major
        && lhs.minor == rhs.minor
        && lhs.patch == rhs.patch
        && lhs.prerelease == rhs.prerelease
        && lhs.buildMetadata == rhs.buildMetadata
}


public func <(lhs: Version, rhs: Version) -> Bool {
    return lhs.major < rhs.major
        || lhs.minor < rhs.minor
        || lhs.patch < rhs.patch
        || lhs.prerelease < rhs.prerelease
        || lhs.buildMetadata < rhs.buildMetadata
}


extension Version : Printable {
    public var description: String {
        return "".join([
            "\(major)",
            minor         != nil ? ".\(minor!)" : "",
            patch         != nil ? ".\(patch!)" : "",
            prerelease    != nil ? "-\(prerelease!)"    : "",
            buildMetadata != nil ? "+\(buildMetadata!)" : ""
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


extension Array {
    func try(index: Int) -> T? {
        if index >= 0  && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}

extension Version: StringLiteralConvertible {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public class func convertFromExtendedGraphemeClusterLiteral(value: ExtendedGraphemeClusterLiteralType) -> Self {
        return self(major: value.toInt()!)
    }

    public class func convertFromStringLiteral(value: StringLiteralType) -> Self {
        let parts = pattern.groupsOfFirstMatch(value)
        println(parts)
        
        let majorStr = parts[1]
        let minorStr = parts.try(2)
        let patchStr = parts.try(3)
        
        let major = majorStr.toInt()
        let minor = minorStr != nil ? minorStr!.toInt() : nil
        let patch = patchStr != nil ? patchStr!.toInt() : nil
        
        return self(major: major!, minor: minor ?? 0, patch: patch ?? 0, prerelease: parts.try(4), buildMetadata: parts.try(5))
    }
}
