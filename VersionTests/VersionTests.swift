//
//  VersionTests.swift
//  VersionTests
//
//  Created by Marius Rackwitz on 07/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Version
import XCTest
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

#if os(iOS)
    import UIKit
#endif

class VersionTests: XCTestCase {
    
    let version = Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1", build: "B001")
    
    func testEquatable() {
        XCTAssert(version == Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1", build: "B001"))
        XCTAssert(version == Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1", build: "B002"))
        
        XCTAssert(version === Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1", build: "B001"))
        XCTAssert(version !== Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1", build: "B002"))
        
        XCTAssert(version != Version(major: 2, minor: 2, patch: 3, prerelease: "alpha.1", build: "B001"))
        XCTAssert(version != Version(major: 1, minor: 3, patch: 3, prerelease: "alpha.1", build: "B001"))
        XCTAssert(version != Version(major: 1, minor: 2, patch: 4, prerelease: "alpha.1", build: "B001"))
        XCTAssert(version != Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.2", build: "B001"))
        XCTAssert(version != Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.2", build: "B002"))
    }
    
    func testHashable() {
        XCTAssertEqual(version.hashValue,    Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1", build: "B001").hashValue)
        XCTAssertNotEqual(version.hashValue, Version(major: 2, minor: 2, patch: 3, prerelease: "alpha.1", build: "B001").hashValue)
        XCTAssertNotEqual(version.hashValue, Version(major: 1, minor: 3, patch: 3, prerelease: "alpha.1", build: "B001").hashValue)
        XCTAssertNotEqual(version.hashValue, Version(major: 1, minor: 2, patch: 4, prerelease: "alpha.1", build: "B001").hashValue)
        XCTAssertNotEqual(version.hashValue, Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.2", build: "B001").hashValue)
        XCTAssertNotEqual(version.hashValue, Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.2", build: "B002").hashValue)
    }
    
    func testStringLiteralConvertible() {
        let otherVersion : Version = "1.2.3-alpha.1+B001"
        XCTAssertEqual(version, otherVersion)
    }
    
    func testPrintable() {
        XCTAssertEqual("1",                  Version(major: 1).description)
        XCTAssertEqual("1.2",                Version(major: 1, minor: 2).description)
        XCTAssertEqual("1.2.3",              Version(major: 1, minor: 2, patch: 3).description)
        XCTAssertEqual("1.2.3-alpha.1",      Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1").description)
        XCTAssertEqual("1.2.3-alpha.1+B001", Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1", build: "B001").description)
    }
    
    func testComparableForIgnoredBuild() {
        let a = Version("1.0.0-alpha+buildA")
        let b = Version("1.0.0-alpha+buildB")
        XCTAssertTrue(a == b)
        XCTAssertTrue(a <= b)
        XCTAssertTrue(a >= b)
        XCTAssertFalse(a < b)
        XCTAssertFalse(a > b)
    }
    
    func testComparable() {
        let versions = [
            Version("1.0.0-alpha"),
            Version("1.0.0-alpha+B001"),
            Version("1.0.0"),
            Version("1.0.0+B001"),
            Version("1.0.3-alpha"),
            Version("1.0.3-alpha+B001"),
            Version("1.0.3"),
            Version("1.0.3+B001"),
            Version("1.2.0-alpha"),
            Version("1.2.0-alpha+B001"),
            Version("1.2.0+B001"),
            Version("1.2.0"),
            Version("1.2.3-alpha"),
            Version("1.2.3-alpha+B001"),
            Version("1.2.3"),
            Version("1.2.3+B001")
        ].map { $0! }
        for (index, less) in versions.enumerated() {
            let range = (index + 1)..<(versions.count)
            for greater in versions[range] {
                XCTAssert(less <= greater)
            }
        }
    }
    
    func testComparableForCanonicalization() {
        let major = Version("1-alpha")
        let majorMinor = Version("1.0-alpha")
        let majorMinorPatch = Version("1.0.0-alpha")
        
        XCTAssertTrue(major == majorMinorPatch)
        XCTAssertTrue(major == majorMinor)
        XCTAssertTrue(majorMinor == majorMinorPatch)
        
        XCTAssertFalse(major < majorMinorPatch)
        XCTAssertFalse(major < majorMinor)
        XCTAssertFalse(majorMinor < majorMinorPatch)
        
        XCTAssertFalse(major > majorMinorPatch)
        XCTAssertFalse(major > majorMinor)
        XCTAssertFalse(majorMinor > majorMinorPatch)
    }
    
    func testComparableForPrereleases() {
        // See http://semver.org/ - 11.
        // Precedence for two pre-release versions with the same major, minor,
        // and patch version MUST be determined by comparing each dot separated
        // identifier from left to right until a difference is found as follows:
        // identifiers consisting of only digits are compared numerically and
        // identifiers with letters or hyphens are compared lexically in ASCII
        // sort order. Numeric identifiers always have lower precedence than
        // non-numeric identifiers. A larger set of pre-release fields has a
        // higher precedence than a smaller set, if all of the preceding
        // identifiers are equal. Example:
        XCTAssert(Version("1.0.0-alpha")      < Version("1.0.0-alpha.1"))
        XCTAssert(Version("1.0.0-alpha.1")    < Version("1.0.0-alpha.beta"))
        XCTAssert(Version("1.0.0-alpha.beta") < Version("1.0.0-beta"))
        XCTAssert(Version("1.0.0-beta")       < Version("1.0.0-beta.2"))
        XCTAssert(Version("1.0.0-beta.2")     < Version("1.0.0-beta.11"))
        XCTAssert(Version("1.0.0-beta.11")    < Version("1.0.0-rc.1"))
        XCTAssert(Version("1.0.0-rc.1")       < Version("1.0.0"))
    }
    
    func testBundleVersion() {
        let mainBundle = Bundle(for: VersionTests.self)
        let path = mainBundle.path(forResource: "Test", ofType: "bundle")
        let testBundle = Bundle(path: path!)!
        XCTAssertEqual(testBundle.shortVersion!, Version(major: 1, minor: 2, patch: 3))
        XCTAssertEqual(testBundle.version!,      version)
    }
    
    func testProcessInfoVersion() {
        let processVersion : Version = ProcessInfo.processInfo.operationSystemVersion
        XCTAssert(processVersion > "7.0.0")
    }
    
}
