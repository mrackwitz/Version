//
//  Version.swift
//  Version
//
//  Created by Marius Rackwitz on 07/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Foundation


public struct Version : Hashable, Comparable {
    public var major: Int
    public var minor: Int?
    public var patch: Int?
    public var prerelease: String?
    public var build: String?
    
    public init(major: Int = 0, minor: Int? = nil, patch: Int? = nil, prerelease: String? = nil, build: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
    }
    
    public init(version: Version) {
        self.major = version.major
        self.minor = version.minor
        self.patch = version.patch
        self.prerelease = version.prerelease
        self.build = version.build
    }
    
    public static func parse(value: String) -> Version? {
        let parts = pattern.groupsOfFirstMatch(value)
        return parts[safe: 1].flatMap { Int($0) }.flatMap { (major: Int) in
            var version = Version(major: major)
            version.minor      = parts[safe: 2].flatMap { Int($0) }
            version.patch      = parts[safe: 3].flatMap { Int($0) }
            version.prerelease = parts[safe: 4]
            version.build      = parts[safe: 5]
            return version
        }
    }
    
    public init!(_ value: String) {
        self = Version.parse(value)!
    }
}


// MARK: Operators
// required by Equatable, Comparable

public func ==(lhs: Version, rhs: Version) -> Bool {
    return lhs.major == rhs.major
        && lhs.minor == rhs.minor
        && lhs.patch == rhs.patch
        && lhs.prerelease == rhs.prerelease
        && lhs.build == rhs.build
}


public func <(lhs: Version, rhs: Version) -> Bool {
    if (lhs.major < rhs.major
     || lhs.minor < rhs.minor
     || lhs.patch < rhs.patch) {
        return true
    }
    
    switch (lhs.prerelease, rhs.prerelease) {
        case (.Some, .None):
            return true
        case (.None, .Some):
            return false
        case (.None, .None):
            break;
        case (.Some(let lpre), .Some(let rpre)):
            let lhsComponents = lpre.componentsSeparatedByString(".")
            let rhsComponents = rpre.componentsSeparatedByString(".")
            let comparables = zip(lhsComponents, rhsComponents)
            for (l, r) in comparables {
                if l != r {
                    if numberPattern.match(l) && numberPattern.match(r) {
                        return Int(l) < Int(r)
                    } else {
                        return l < r
                    }
                }
            }
            if lhsComponents.count != rhsComponents.count {
                return lhsComponents.count < rhsComponents.count
            }
    }
    
    return lhs.build < rhs.build
}

extension Version : Hashable {
    public var hashValue: Int {
        let majorHash = major.hashValue
        let minorHash = minor?.hashValue ?? 0
        let patchHash = patch?.hashValue ?? 0
        let prereleaseHash = prerelease?.hashValue ?? 0
        let buildHash = build?.hashValue ?? 0
        let prime = 31
        return reduce([majorHash, minorHash, patchHash, prereleaseHash, buildHash], 0) { $0 &* prime &+ $1 }
    }
}

// MARK: String conversion

extension Version : CustomStringConvertible {
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


let pattern : Regex = "([0-9]+)(?:\\.([0-9]+))?(?:\\.([0-9]+))?(?:-([0-9A-Za-z-.]+))?(?:\\+([0-9A-Za-z-]+))?"
let numberPattern : Regex = "[0-9]+"
let anchoredPattern = try! Regex(pattern: "/\\A\\s*(\(pattern.pattern))?\\s*\\z/")

extension Version {
    public static func valid(string: String) -> Bool {
        return anchoredPattern.match(string)
    }
}


extension Version: StringLiteralConvertible {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}


// MARK: Foundation extensions

extension NSBundle {
    public var version : Version? {
        return self.versionFromInfoDicitionary(forKey: String(kCFBundleVersionKey))
    }
    
    public var shortVersion : Version? {
        return self.versionFromInfoDicitionary(forKey: "CFBundleShortVersionString")
    }
    
    func versionFromInfoDicitionary(forKey key: String) -> Version? {
        if let bundleVersion = self.infoDictionary?[key] as? NSString {
            return Version.parse(String(bundleVersion))
        }
        return nil
    }
}

extension NSProcessInfo {
    @available(iOS, introduced=8.0)
    public var operationSystemVersion: Version {
        let version : NSOperatingSystemVersion = self.operatingSystemVersion
        return Version(
            major: version.majorVersion,
            minor: version.minorVersion,
            patch: version.patchVersion
        )
    }
}


// MARK: UIKit extensions

#if os(iOS)
    import UIKit

    extension UIDevice {
        public var systemVersion: Version? {
            return Version(self.systemVersion())
        }
    }

#endif
