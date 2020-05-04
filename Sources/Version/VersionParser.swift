//
//  VersionParser.swift
//  Version
//
//  Created by Vincent Esche on 8/9/15.
//  Copyright © 2015 Vincent Esche. All rights reserved.
//

import Foundation

enum VersionParserError: Error {
    case MissingMinorComponent
    case MissingPatchComponent
    case InvalidComponents
    case InvalidMajorComponent
    case InvalidMinorComponent
    case InvalidPatchComponent
}

public struct VersionParser {
    static func versionPattern(strict: Bool, anchored: Bool) -> Regex {
        let number = VersionParser.numberPatternString(strict: strict)
        let version: String
        if strict {
            version = "(\(number))\\.(\(number))\\.(\(number))"
        } else {
            version = "(\(number))(?:\\.(\(number)))?(?:\\.(\(number)))?"
        }
        let prerelease = "(?:-([0-9A-Za-z-.]+))?(?:\\+([0-9A-Za-z-]+))?"
        let pattern: String
        if anchored {
            pattern = "\\A\(version + prerelease)?\\z"
        } else {
            pattern = version + prerelease
        }
        return try! Regex(pattern: pattern)
    }

    private static func numberPatternString(strict: Bool) -> String {
        if strict {
            return "0|[1-9][0-9]*"
        } else {
            return "[0-9]+"
        }
    }

    static func numberPattern(strict: Bool, anchored: Bool) -> Regex {
        let numberPattern = VersionParser.numberPatternString(strict: strict)
        let pattern: String
        if anchored {
            pattern = "\\A\(numberPattern)?\\z"
        } else {
            pattern = numberPattern
        }
        return try! Regex(pattern: pattern)
    }

    let strict: Bool
    let versionRegex: Regex
    let numberRegex: Regex

    public init(strict: Bool = true) {
        self.strict = strict
        self.versionRegex = VersionParser.versionPattern(strict: self.strict, anchored: true)
        self.numberRegex = VersionParser.numberPattern(strict: self.strict, anchored: true)
    }

    public func parse(string: String) throws -> Version {
        let components = self.versionRegex.groupsOfFirstMatch(string: string)
        return try self.parse(components: components)
    }

    public func parse(components: [String?]) throws -> Version {
        var version = Version()

        if components.count != 6 { // all, major, minor, patch, prerelease, build
            throw VersionParserError.InvalidComponents
        }

        if self.strict {
            if components[2] == nil {
                throw VersionParserError.MissingMinorComponent
            } else if components[3] == nil {
                throw VersionParserError.MissingPatchComponent
            }
        }

        let majorComponent = components[1]
        let minorComponent = components[2]
        let patchComponent = components[3]

        if let major = majorComponent.flatMap({ Int($0) }) {
            version.major = major
        } else {
            throw VersionParserError.InvalidMajorComponent
        }

        if let minor = minorComponent.flatMap({ Int($0) }) {
            version.minor = minor
        } else if minorComponent != nil {
            throw VersionParserError.InvalidMinorComponent
        }

        if let patch = patchComponent.flatMap({ Int($0) }) {
            version.patch = patch
        } else if patchComponent != nil {
            throw VersionParserError.InvalidPatchComponent
        }

        version.prerelease = components[4]
        version.build = components[5]

        return version
    }
}
