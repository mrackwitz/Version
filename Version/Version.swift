//
//  Version.swift
//  Version
//
//  Created by Marius Rackwitz on 07/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Foundation


/// Represents a version aligning to [SemVer 2.0.0](http://semver.org).
public struct Version {
    /// The major component of the version.
    ///
    /// - Note:
    /// > Increment the MAJOR version when you make incompatible API changes.
    ///
    public var major: Int
    
    /// An optional minor component of the version.
    ///
    /// - Note:
    /// > Increment the MINOR version when you add functionality in a backwards-compatible manner.
    ///
    public var minor: Int?
    
    /// An optional patch component of the version.
    ///
    /// - Note:
    /// > Increment the PATCH version when make backwards-compatible bug fixes.
    ///
    public var patch: Int?
    
    /// An optional prerelease component of the version.
    ///
    /// - Note:
    /// > A pre-release version MAY be denoted by appending a hyphen and a series of dot separated
    /// > identifiers immediately following the patch version. Identifiers MUST comprise only ASCII
    /// > alphanumerics and hyphen [0-9A-Za-z-]. Identifiers MUST NOT be empty. Numeric identifiers
    /// > MUST NOT include leading zeroes. Pre-release versions have a lower precedence than the
    /// > associated normal version. A pre-release version indicates that the version is unstable
    /// > and might not satisfy the intended compatibility requirements as denoted by its associated
    /// > normal version.
    ///
    /// #### Examples:
    ///
    ///    * `1.0.0-alpha`
    ///    * `1.0.0-alpha.1`
    ///    * `1.0.0-0.3.7`
    ///    * `1.0.0-x.7.z.92`
    ///
    public var prerelease: String?
    
    /// An optional build component of the version.
    public var build: String?
    
    /// Initialize a version from its components.
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
    
    /// Parse a version number from a string representation.
    ///
    /// - Parameter value: the string representations
    /// - Returns: the parsed version number or `nil`,
    ///   if the version is invalid.
    ///
    public static func parse(value: String) -> Version? {
        let parts = pattern.groupsOfFirstMatch(value)
        
        if let major = parts.try(1)?.toInt() {
            return Version(
                major: major,
                minor: parts.try(2)?.toInt(),
                patch: parts.try(3)?.toInt(),
                prerelease: parts.try(4),
                build: parts.try(5)
            )
        } else {
            return nil
        }
    }
    
    /// Initialize a version from its string representation.
    public init!(_ value: String) {
        self = Version.parse(value)!
    }
}


// MARK: - Equatable

extension Version : Equatable {}

public func ==(lhs: Version, rhs: Version) -> Bool {
    return lhs.major == rhs.major
        && lhs.minor == rhs.minor
        && lhs.patch == rhs.patch
        && lhs.prerelease == rhs.prerelease
        && lhs.build == rhs.build
}


// MARK: - Comparable

extension Version : Comparable {}

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


// MARK: - Hashable

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


// MARK: String Conversion

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


// MARK: Foundation Extensions

extension NSBundle {
    /// The marketing version number of the bundle.
    public var version : Version? {
        return self.versionFromInfoDicitionary(forKey: String(kCFBundleVersionKey))
    }
    
    /// The short version number of the bundle.
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
    /// The version of the operating system on which the process is executing.
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


// MARK: UIKit Extensions

#if os(iOS)
    import UIKit

    extension UIDevice {
        /// The current version of the operating system.
        public var systemVersion: Version? {
            return Version(self.systemVersion())
        }
    }

#endif
