# Version

[![CI Status](http://img.shields.io/travis/mrackwitz/Version.svg?style=flat)](https://travis-ci.org/mrackwitz/Version)

Version is a Swift Library, which enables to represent and compare semantic version numbers.
It follows [Semantic Versioning 2.0.0](http://semver.org).

The representation is:

* Comparable
* Hashable & Equatable
* String Literal Convertible
* Printable

## Usage

Versions could be either instantiated directly:

```swift
let version = Version(
    major: 1,
    minor: 2,
    patch: 3,
    prerelease: "alpha.1",
    build: "B001"
)
```

Or they can be converted from a string representation:

```swift
let version = try Version("1.2.3-alpha.1+B001")

let version: Version = "1.2.3-alpha.1+B001"
// The line above is equivalent to:
let version = try! Version("1.2.3-alpha.1+B001")
```

Versions can be compared between each other:

```swift
let version = Version(from: ProcessInfo.processInfo.operatingSystemVersion)

if version > "8.0.0" {
    // do something in a more amazing way
} else if version > "7.0.0"
    // do it an old-fashioned, legacy-style
} else {
    // do not care …
}
```

Besides UIKit's `UIDevice` the more preferable variant to access
the operation system version in Foundation as shown below is supported, too.

```swift
let version = Version(from: ProcessInfo.processInfo.operatingSystemVersion)
if version == "8.0.1" {
    NSLog("Sorry no cellular data for you, my friend!")
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
for definitions, which have been passed to the compiler build setting
`OTHER_SWIFT_FLAGS`.

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/mrackwitz/Version.git", …),
```

### Cocoapods

Version is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod 'Version'
```

### Carthage

```ruby
github "mrackwitz/Version"
```

## Author

Marius Rackwitz, git@mariusrackwitz.de  
Find me on Twitter as [@mrackwitz](https://twitter.com/mrackwitz).

## License

Version is available under the MIT license. See the LICENSE file for more info.
