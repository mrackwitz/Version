//
//  VersionParserTests.swift
//  Version
//
//  Created by Vincent Esche on 8/9/15.
//  Copyright © 2015 Vincent Esche. All rights reserved.
//

import XCTest

import Version

/*
#!/usr/bin/ruby

# Ruby script used for generating carthesian product of version components:

major = ['1']
minor = ['.2', '.0']
patch = ['.3', '.0']
prerelease = ['-alpha', '']
build = ['+deadbeef', '']
product = major.product(minor, patch, prerelease, build)
versions = product.map(&:join)
puts versions.sort
*/

class VersionParserTests: XCTestCase {
    var validStrings: [String] {
        return [
            "1.0.0-alpha",
            "1.0.0-alpha+deadbeef",
            "1.0.0",
            "1.0.0+deadbeef",
            "1.0.3-alpha",
            "1.0.3-alpha+deadbeef",
            "1.0.3",
            "1.0.3+deadbeef",
            "1.2.0-alpha",
            "1.2.0-alpha+deadbeef",
            "1.2.0+deadbeef",
            "1.2.0",
            "1.2.3-alpha",
            "1.2.3-alpha+deadbeef",
            "1.2.3",
            "1.2.3+deadbeef",
        ]
    }
    
    var semiValidStrings: [String] {
        return [
            "1-alpha",
            "1.0-alpha",
            "1-alpha+deadbeef",
            "1.0-alpha+deadbeef",
            "1",
            "1.0",
            "1+deadbeef",
            "1.0+deadbeef",
            "1.2-alpha",
            "1.2-alpha+deadbeef",
            "1.2+deadbeef",
            "1.2",
            "01.2.3",
            "1.02.3",
            "1.2.03",
        ]
    }
    
    var invalidStrings: [String] {
        return [
            "",
            "lorem ipsum",
            "a.0.0-alpha+deadbeef",
            "0.b.0-alpha+deadbeef",
            "0.0.c-alpha+deadbeef",
            "0.0.0- +deadbeef",
            "0.0.0-+deadbeef",
            "0.0.0-+",
            "0.0.0-_+deadbeef",
            "0.0.0-alpha+_"
        ]
    }
    
    var validVersions: [Version] {
        return [
            Version(major: 1, minor: 0, patch:0, prerelease: "alpha"),
            Version(major: 1, minor: 0, patch:0, prerelease: "alpha", build: "deadbeef"),
            Version(major: 1, minor: 0, patch:0),
            Version(major: 1, minor: 0, patch:0, build: "deadbeef"),
            Version(major: 1, minor: 0, patch:3, prerelease: "alpha"),
            Version(major: 1, minor: 0, patch:3, prerelease: "alpha", build: "deadbeef"),
            Version(major: 1, minor: 0, patch:3),
            Version(major: 1, minor: 0, patch:3, build: "deadbeef"),
            Version(major: 1, minor: 2, patch:0, prerelease: "alpha"),
            Version(major: 1, minor: 2, patch:0, prerelease: "alpha", build: "deadbeef"),
            Version(major: 1, minor: 2, patch:0, build: "deadbeef"),
            Version(major: 1, minor: 2, patch:0),
            Version(major: 1, minor: 2, patch:3, prerelease: "alpha"),
            Version(major: 1, minor: 2, patch:3, prerelease: "alpha", build: "deadbeef"),
            Version(major: 1, minor: 2, patch:3),
            Version(major: 1, minor: 2, patch:3, build: "deadbeef"),
        ]
    }
    
    var semiValidVersions: [Version] {
        return [
            Version(major: 1, prerelease: "alpha"),
            Version(major: 1, minor: 0, prerelease: "alpha"),
            Version(major: 1, prerelease: "alpha", build: "deadbeef"),
            Version(major: 1, minor: 0, prerelease: "alpha", build: "deadbeef"),
            Version(major: 1),
            Version(major: 1, minor: 0),
            Version(major: 1, build: "deadbeef"),
            Version(major: 1, minor: 0, build: "deadbeef"),
            Version(major: 1, minor: 2, prerelease: "alpha"),
            Version(major: 1, minor: 2, prerelease: "alpha", build: "deadbeef"),
            Version(major: 1, minor: 2, build: "deadbeef"),
            Version(major: 1, minor: 2),
            Version(major: 1, minor: 2, patch: 3),
            Version(major: 1, minor: 2, patch: 3),
            Version(major: 1, minor: 2, patch: 3),
        ]
    }
    
    func testStrictParsingOfValidStrings() {
        let parser = VersionParser(strict: true)
        for (string, version) in zip(self.validStrings, self.validVersions) {
            do {
                let parsedVersion = try parser.parse(string: string)
                XCTAssert(parsedVersion === version)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }

    func testStrictParsingOfSemiValidStrings() {
        let parser = VersionParser(strict: true)
        for string in self.semiValidStrings {
            XCTAssertThrowsError(try parser.parse(string: string))
        }
    }
    
    func testStrictParsingOfInvalidStrings() {
        let parser = VersionParser(strict: true)
        for string in self.invalidStrings {
            XCTAssertThrowsError(try parser.parse(string: string))
        }
    }
    
    func testLenientParsingOfValidStrings() {
        let parser = VersionParser(strict: false)
        for (string, version) in zip(self.validStrings, self.validVersions) {
            do {
                let parsedVersion = try parser.parse(string: string)
                XCTAssert(parsedVersion === version)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testLenientParsingOfSemiValidStrings() {
        let parser = VersionParser(strict: false)
        for (string, version) in zip(self.semiValidStrings, self.semiValidVersions) {
            do {
                let parsedVersion = try parser.parse(string: string)
                XCTAssert(parsedVersion === version)
            } catch let error {
                XCTFail("\(error)")
            }
        }
    }
    
    func testLenientParsingOfInvalidStrings() {
        let parser = VersionParser(strict: false)
        for string in self.invalidStrings {
            XCTAssertThrowsError(try parser.parse(string: string))
        }
    }
}
