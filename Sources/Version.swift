//
//  Version.swift
//  Version
//
//  Created by Marius Rackwitz on 07/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Foundation

let strictVersionParser = VersionParser(strict: true)
let lenientVersionParser = VersionParser(strict: false)

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
    
    /// Canonicalized form of minor component of the version.
    ///
    public var canonicalMinor: Int {
        return self.minor ?? 0
    }
    
    /// An optional patch component of the version.
    ///
    /// - Note:
    /// > Increment the PATCH version when make backwards-compatible bug fixes.
    ///
    public var patch: Int?
    
    /// Canonicalized form of patch component of the version.
    ///
    public var canonicalPatch: Int {
        return self.patch ?? 0
    }
    
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
    
    /// Initialize a version from its string representation.
    public init!(_ value: String) {
        do {
            let parser = VersionParser(strict: false)
            self = try parser.parse(string: value)
        } catch let error {
            print("Error: Failed to parse version number '\(value)': \(error)")
            return nil
        }
    }
    
    /// Canonicalize version by replacing nil components with their defaults
    public mutating func canonicalize() {
        self.minor = self.minor ?? 0
        self.patch = self.patch ?? 0
    }
    
    /// Create canonicalized copy
    public func canonicalized() -> Version {
        var copy = self
        copy.canonicalize()
        return copy
    }
}


// MARK: - Equatable

extension Version : Equatable {}

public func ==(lhs: Version, rhs: Version) -> Bool {
    let equalMajor = lhs.major == rhs.major
    let equalMinor = lhs.canonicalMinor == rhs.canonicalMinor
    let equalPatch = lhs.canonicalPatch == rhs.canonicalPatch
    let equalPrerelease = lhs.prerelease == rhs.prerelease
    return equalMajor && equalMinor && equalPatch && equalPrerelease
}

public func ===(lhs: Version, rhs: Version) -> Bool {
    return (lhs == rhs) && (lhs.build == rhs.build)
}

public func !==(lhs: Version, rhs: Version) -> Bool {
    return !(lhs === rhs)
}


// MARK: - Comparable

extension Version : Comparable {}

public func <=(lhs: Version, rhs: Version) -> Bool {
    return lhs < rhs || lhs == rhs
}

public func <(lhs: Version, rhs: Version) -> Bool {
    if (lhs.major < rhs.major
     || lhs.canonicalMinor < rhs.canonicalMinor
     || lhs.canonicalPatch < rhs.canonicalPatch) {
        return true
    }

    switch (lhs.prerelease, rhs.prerelease) {
    case (.some, .none):
            return true
    case (.none, .some):
            return false
    case (.none, .none):
            break;
    case (.some(let lpre), .some(let rpre)):
        let lhsComponents = lpre.components(separatedBy: ".")
        let rhsComponents = rpre.components(separatedBy: ".")
            let comparables = zip(lhsComponents, rhsComponents)
            for (l, r) in comparables {
                if l != r {
                    let regex = lenientVersionParser.numberRegex
                    if regex.match(string: l) && regex.match(string: r) {
                        return (Int(l) ?? 0) < (Int(r) ?? 0)
                    } else {
                        return l < r
                    }
                }
            }
            if lhsComponents.count != rhsComponents.count {
                return lhsComponents.count < rhsComponents.count
            }
    }
    return false
}


// MARK: - Hashable

extension Version : Hashable {
    public var hashValue: Int {
        let majorHash = self.major.hashValue
        let minorHash = self.canonicalMinor.hashValue
        let patchHash = self.canonicalPatch.hashValue
        let prereleaseHash = self.prerelease?.hashValue ?? 0
        let prime = 31
        return [majorHash, minorHash, patchHash, prereleaseHash].reduce(0) { $0 &* prime &+ $1 }
    }
}


// MARK: String Conversion

extension Version : CustomStringConvertible {
    public var description: String {
        return [
            "\(major)",
            minor      != nil ? ".\(minor!)"      : "",
            patch      != nil ? ".\(patch!)"      : "",
            prerelease != nil ? "-\(prerelease!)" : "",
            build      != nil ? "+\(build!)"      : ""
            ].joined(separator: "")
    }
}

extension Version {
    public static func valid(string: String, strict: Bool = false) -> Bool {
        return strictVersionParser.versionRegex.match(string: string)
    }
}

extension Version: ExpressibleByStringLiteral {
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

extension Bundle {
    /// The marketing version number of the bundle.
    public var version : Version? {
        return self.versionFromInfoDicitionary(forKey: String(kCFBundleVersionKey))
    }
    
    /// The short version number of the bundle.
    public var shortVersion : Version? {
        return self.versionFromInfoDicitionary(forKey: "CFBundleShortVersionString")
    }
    
    func versionFromInfoDicitionary(forKey key: String) -> Version? {
        guard let dictionary = self.infoDictionary else {
            return nil
        }
        guard let bundleVersion = dictionary[key] as? String else {
            return nil
        }
        do {
            return try lenientVersionParser.parse(string: bundleVersion)
        } catch {
            return nil
        }
    }
}

extension ProcessInfo {
    /// The version of the operating system on which the process is executing.
    @available(OSX, introduced: 10.10)
    @available(iOS, introduced: 8.0)
    public var operationSystemVersion: Version {
        let version : OperatingSystemVersion = self.operatingSystemVersion
        return Version(
            major: version.majorVersion,
            minor: version.minorVersion,
            patch: version.patchVersion
        )
    }
}
