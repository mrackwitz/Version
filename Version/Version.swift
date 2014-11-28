//
//  Version.swift
//  Version
//
//  Created by Marius Rackwitz on 07/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Foundation


public struct Version : Equatable, Comparable {
    public let major: Int
    public let minor: Int?
    public let patch: Int?
    public let prerelease: String?
    public let build: String?
    
    public init(major: Int = 0, minor: Int? = nil, patch: Int? = nil, prerelease: String? = nil, build: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
    }
    
    public init?(_ value: String) {
        let parts = pattern.groupsOfFirstMatch(value)
        
        let majorStr = parts[1]
        if let major = majorStr.toInt() {
            self.major = major
        } else {
            return nil
        }
        
        let minorStr = parts.try(2)
        let patchStr = parts.try(3)
        
        self.minor      = minorStr?.toInt()
        self.patch      = patchStr?.toInt()
        self.prerelease = parts.try(4)
        self.build      = parts.try(5)
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
        case let (lpre, rpre):
            let lhsComponents = lpre!.componentsSeparatedByString(".")
            let rhsComponents = rpre!.componentsSeparatedByString(".")
            let comparisables = Zip2(lhsComponents, rhsComponents)
            for pair in comparisables {
                if pair.0 != pair.1 {
                    if numberPattern.match(pair.0) && numberPattern.match(pair.1) {
                        return pair.0.toInt() < pair.1.toInt()
                    } else {
                        return pair.0 < pair.1
                    }
                }
            }
            if lhsComponents.count != rhsComponents.count {
                return lhsComponents.count < rhsComponents.count
            }
        default:
            break
    }
    
    return lhs.build < rhs.build
}


// MARK: String conversion

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


let pattern = Regex(pattern: "([0-9]+)(?:\\.([0-9]+))?(?:\\.([0-9]+))?(?:-([0-9A-Za-z-.]+))?(?:\\+([0-9A-Za-z-]+))?")!
let numberPattern = Regex(pattern: "[0-9]+")!
let anchoredPattern = Regex(pattern: "/\\A\\s*(\(pattern.pattern))?\\s*\\z/")!

extension Version {
    public static func valid(string: String) -> Bool {
        return anchoredPattern.match(string)
    }
}


extension Version: StringLiteralConvertible {
    public typealias UnicodeScalarLiteralType = Character
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init("\(value)")
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(value)
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
            return Version(String(bundleVersion))
        }
        return nil
    }
}

extension NSProcessInfo {
    @availability(iOS, introduced=8.0)
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
        public func systemVersion() -> Version? {
            return Version(self.systemVersion())
        }
    }

#endif
