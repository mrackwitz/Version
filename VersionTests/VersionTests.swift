//
//  VersionTests.swift
//  VersionTests
//
//  Created by Marius Rackwitz on 07/09/14.
//  Copyright (c) 2014 Marius Rackwitz. All rights reserved.
//

import Version
import XCTest

class VersionTests: XCTestCase {
    
    let version = Version(major: 1, minor: 2, patch: 3, prerelease: "alpha1", build: "B001")
    
    func testEquatable() {
        XCTAssertEqual(version,    Version(major: 1, minor: 2, patch: 3, prerelease: "alpha1", build: "B001"))
        XCTAssertNotEqual(version, Version(major: 2, minor: 2, patch: 3, prerelease: "alpha1", build: "B001"))
        XCTAssertNotEqual(version, Version(major: 1, minor: 3, patch: 3, prerelease: "alpha1", build: "B001"))
        XCTAssertNotEqual(version, Version(major: 1, minor: 2, patch: 4, prerelease: "alpha1", build: "B001"))
        XCTAssertNotEqual(version, Version(major: 1, minor: 2, patch: 3, prerelease: "alpha2", build: "B001"))
        XCTAssertNotEqual(version, Version(major: 1, minor: 2, patch: 3, prerelease: "alpha2", build: "B002"))
    }
    
    func testStringLiteralConvertible() {
        let otherVersion : Version = "1.2.3-alpha1+B001"
        XCTAssertEqual(version, otherVersion)
    }
    
    func testPrintable() {
        XCTAssertEqual("1",                 Version(major: 1).description)
        XCTAssertEqual("1.2",               Version(major: 1, minor: 2).description)
        XCTAssertEqual("1.2.3",             Version(major: 1, minor: 2, patch: 3).description)
        XCTAssertEqual("1.2.3-alpha1",      Version(major: 1, minor: 2, patch: 3, prerelease: "alpha1").description)
        XCTAssertEqual("1.2.3-alpha1+B001", Version(major: 1, minor: 2, patch: 3, prerelease: "alpha1", build: "B001").description)
    }
    
    func testComparable() {
        XCTAssert(version < "2.0")
        XCTAssert(version < "1.3")
        XCTAssert(version < "1.2.4")
        XCTAssert(version < "1.2.3-alpha1+B002")
        XCTAssert(version < "1.2.3-alpha2+B001")
        XCTAssert(version <= "1.2.3-alpha1+B001")
        XCTAssert(version > "1.2.2")
        XCTAssert(version > "1.1.3")
        // XCTAssert(version < "1.2.3") !? semver.org
        XCTAssert(version > "1")
        XCTAssert(version > "0.1")
        XCTAssert(version > "0.0.1")
    }
    
}
