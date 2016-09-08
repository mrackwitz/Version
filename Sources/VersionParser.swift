//
//  VersionParser.swift
//  Version
//
//  Created by Vincent Esche on 8/9/15.
//  Copyright © 2015 Vincent Esche. All rights reserved.
//

import Foundation

enum VersionParserError: Error {
    case missingMinorComponent
    case missingPatchComponent
    case invalidComponents
    case invalidMajorComponent
    case invalidMinorComponent
    case invalidPatchComponent
}

public struct VersionParser {
    
    static func versionPattern(strict: Bool, anchored: Bool) -> Regex {
        let pattern: String
        if strict {
            pattern = "(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(?:-([0-9A-Za-z-.]+))?(?:\\+([0-9A-Za-z-]+))?"
        } else {
            pattern = "([0-9]+)(?:\\.([0-9]+))?(?:\\.([0-9]+))?(?:-([0-9A-Za-z-.]+))?(?:\\+([0-9A-Za-z-]+))?"
        }
        return try! Regex(pattern: (anchored) ? "\\A\(pattern)?\\z" : pattern)
    }
    
    static func numberPattern(strict: Bool, anchored: Bool) -> Regex {
        let pattern: String
        if strict {
            pattern = "0|[1-9][0-9]*"
        } else {
            pattern = "[0-9]+"
        }
        return try! Regex(pattern: (anchored) ? "\\A\(pattern)?\\z" : pattern)
    }
    
    let strict: Bool
    let versionRegex: Regex
    let numberRegex: Regex
    
    public init(strict: Bool = true) {
        self.strict = strict
        self.versionRegex = VersionParser.versionPattern(strict: self.strict, anchored: true)
        self.numberRegex = VersionParser.numberPattern(strict: self.strict, anchored: true)
    }
    
    public func parse(_ string: String) throws -> Version {
        let components = self.versionRegex.groupsOfFirstMatch(string)
        return try self.parse(components)
    }
    
    public func parse(_ components: [String?]) throws -> Version {
        var version = Version()
        
        if components.count != 6 { // all, major, minor, patch, prerelease, build
            throw VersionParserError.invalidComponents
        }
        
        if self.strict {
            if components[2] == nil {
                throw VersionParserError.missingMinorComponent
            } else if components[3] == nil {
                throw VersionParserError.missingPatchComponent
            }
        }
        
        let majorComponent = components[1]
        let minorComponent = components[2]
        let patchComponent = components[3]
        
        if let major = majorComponent.flatMap({ Int($0) }) {
            version.major = major
        } else {
            throw VersionParserError.invalidMajorComponent
        }
        
        if let minor = minorComponent.flatMap({ Int($0) }) {
            version.minor = minor
        } else if minorComponent != nil {
            throw VersionParserError.invalidMinorComponent
        }
        
        if let patch = patchComponent.flatMap({ Int($0) }) {
            version.patch = patch
        } else if patchComponent != nil {
            throw VersionParserError.invalidPatchComponent
        }
        
        version.prerelease = components[4]
        version.build = components[5]
        
        return version
    }
}
