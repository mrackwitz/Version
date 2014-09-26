# Version
[![CI Status](http://img.shields.io/travis/mrackwitz/Version.svg?style=flat)](https://travis-ci.org/mrackwitz/Version)
[![Version](https://img.shields.io/cocoapods/v/Version.svg?style=flat)](http://cocoadocs.org/docsets/Version)
[![License](https://img.shields.io/cocoapods/l/Version.svg?style=flat)](http://cocoadocs.org/docsets/Version)
[![Platform](https://img.shields.io/cocoapods/p/Version.svg?style=flat)](http://cocoadocs.org/docsets/Version)

Version is a Swift Library, which enables to represent and compare semantic version numbers.
It follows [Semantic Versioning 2.0.0](http://semver.org).

The representation is:

* Comparable
* Equatable
* String Literal Convertible
* Printable


## Usage

Versions could be either instantiated directly:

```swift
let version = Version(major: 1, minor: 2, patch: 3, prerelease: "alpha.1", build: "B001")
```

Or they can be converted from a string literal:

```swift
let version : Version = "1.2.3-alpha.1+B001"
```

Versions can be compared between each other:

```swift
if version > "2.0" {
    // do something in a more amazing way
} else if version > "1.2"
    // do it an old-fashioned, legacy-style
} else {
    // do not care …
}
```

Finally Versions can be directly read from bundles:

```swift
if NSBundle(path: "Alamofire.framework").version! < "1.0.0" {
    println("Howdy Ho! Such an early-adopter using an unstable version!")
    println("Beware: “Anything may change at any time.”")

    // … or insert an actual meaningful special handling
    // for version-specific *implementation details* here.
}
```

**ATTENTION**: Take care when you check versions of frameworks.
Such checks happen at runtime. They can hurt performance if used at the wrong
place. If there are API changes and you want to consume new methods, you have
to do that at compile time by checking with precompiler macros (`#if`)
for definitions, which have beeen passed to the compiler build setting
`OTHER_SWIFT_FLAGS`.

## Installation

Version is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "Version"
```

As soon as CocoaPods supports Swift. (cooming soon :wink:)


## Author

Marius Rackwitz, git@mariusrackwitz.de  
Find me on Twitter as [@mrackwitz](https://twitter.com/mrackwitz).


## License

Version is available under the MIT license. See the LICENSE file for more info.
