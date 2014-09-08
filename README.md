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
let version = Version(major: 1, minor: 2, patch: 3, prerelease: "alpha1", build: "B001")
```

Or they can be converted from a string literal:

```swift
let version : Version = "1.2.3-alhpa1+B001"
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

## Installation

Version is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "Version"
```

As soon as CocoaPods supports Swift. (cooming soon :wink:)


## Author

Marius Rackwitz, git@mariusrackwitz.de


## License

Version is available under the MIT license. See the LICENSE file for more info.

