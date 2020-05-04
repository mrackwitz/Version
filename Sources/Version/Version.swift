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
    public var major: Int {
        didSet {
            precondition(self.major >= 0, "Must be non-negative integer")
        }
    }

    /// An optional minor component of the version.
    ///
    /// - Note:
    /// > Increment the MINOR version when you add functionality in a backwards-compatible manner.
    ///
    public var minor: Int? {
        didSet {
            guard let minor = self.minor else {
                return
            }
            precondition(minor >= 0, "Must be non-negative integer")
        }
    }

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
    public var patch: Int? {
        didSet {
            guard let patch = self.patch else {
                return
            }
            precondition(patch >= 0, "Must be non-negative integer")
        }
    }

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

    fileprivate static let strictParser = VersionParser(strict: true)
    fileprivate static let lenientParser = VersionParser(strict: false)

    /// Initialize a version from its components.
    public init(
        major: Int = 0,
        minor: Int? = nil,
        patch: Int? = nil,
        prerelease: String? = nil,
        build: String? = nil
    ) {
        precondition(major >= 0, "Must be non-negative integer")
        if let minor = minor {
            precondition(minor >= 0, "Must be non-negative integer")
        }
        if let patch = patch {
            precondition(patch >= 0, "Must be non-negative integer")
        }

        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
    }

    /// Initialize a version from its (non-strict) string representation, or throw.
    public init(_ string: String, strict: Bool = false) throws {
        let parser = VersionParser(strict: strict)
        self = try parser.parse(string: string)
    }

    /// Initialize a version from a `OperatingSystemVersion`.
    public init(from version: OperatingSystemVersion) {
        self.init(
            major: version.majorVersion,
            minor: version.minorVersion,
            patch: version.patchVersion
        )
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

    fileprivate static func compare<T: Comparable>(lhs: T, rhs: T) -> ComparisonResult {
        if lhs < rhs {
            return .orderedAscending
        } else if lhs > rhs {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }

    fileprivate static func compareNumeric(lhs: String, rhs: String) -> ComparisonResult {
        let lhsComponents = lhs.components(separatedBy: ".")
        let rhsComponents = rhs.components(separatedBy: ".")
        let comparables = zip(lhsComponents, rhsComponents)
        let firstDifferentComponent = comparables.first { $0.0 != $0.1 }
        if let (l, r) = firstDifferentComponent {
            let regex = Version.lenientParser.numberRegex
            if regex.match(string: l) && regex.match(string: r) {
                return self.compare(lhs: Int(l) ?? 0, rhs: Int(r) ?? 0)
            } else {
                return self.compare(lhs: l, rhs: r)
            }
        }
        if lhsComponents.count != rhsComponents.count {
            return self.compare(lhs: lhsComponents.count, rhs: rhsComponents.count)
        }
        return .orderedSame
    }
}


// MARK: - Equatable

extension Version: Equatable {}

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

extension Version: Comparable {}

public func <(lhs: Version, rhs: Version) -> Bool {
    let majorComparison = Version.compare(lhs: lhs.major, rhs: rhs.major)
    if majorComparison != .orderedSame {
        return majorComparison == .orderedAscending
    }

    let minorComparison = Version.compare(lhs: lhs.canonicalMinor, rhs: rhs.canonicalMinor)
    if minorComparison != .orderedSame {
        return minorComparison == .orderedAscending
    }

    let patchComparison = Version.compare(lhs: lhs.canonicalPatch, rhs: rhs.canonicalPatch)
    if patchComparison != .orderedSame {
        return patchComparison == .orderedAscending
    }

    switch (lhs.prerelease, rhs.prerelease) {
    case (.some, .none):
        return true
    case (.none, .some):
        return false
    case (.none, .none):
        return false
    case (.some(let lpre), .some(let rpre)):
        let prereleaseComparison = Version.compareNumeric(lhs: lpre, rhs: rpre)
        return prereleaseComparison == .orderedAscending
    }
}

// MARK: - Hashable

extension Version: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(canonicalMinor)
        hasher.combine(canonicalPatch)
        hasher.combine(prerelease)
    }
}

// MARK: String Conversion

extension Version: CustomStringConvertible {
    public var description: String {
        let components: [String] = [
            "\(major)",
            minor      != nil ? ".\(minor!)"      : "",
            patch      != nil ? ".\(patch!)"      : "",
            prerelease != nil ? "-\(prerelease!)" : "",
            build      != nil ? "+\(build!)"      : ""
        ]
        return components.joined(separator: "")
    }
}

extension Version {
    public static func valid(string: String, strict: Bool = false) -> Bool {
        return Version.strictParser.versionRegex.match(string: string)
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
        try! self.init(value)
    }
}

extension Version: Codable {}

// MARK: Foundation Extensions

extension Bundle {
    /// The marketing version number of the bundle.
    public var version: Version? {
        #if os(Linux)
        return nil
        #else
        return self.versionFromInfoDictionary(forKey: String(kCFBundleVersionKey))
        #endif
    }

    /// The short version number of the bundle.
    public var shortVersion: Version? {
        return self.versionFromInfoDictionary(forKey: "CFBundleShortVersionString")
    }

    internal func versionFromInfoDictionary(forKey key: String) -> Version? {
        guard let dictionary = self.infoDictionary else {
            return nil
        }
        guard let bundleVersion = dictionary[key] as? String else {
            return nil
        }
        do {
            return try Version.lenientParser.parse(string: bundleVersion)
        } catch {
            return nil
        }
    }
}
