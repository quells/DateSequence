# DateSequence

[![CI Status](https://img.shields.io/travis/quells/DateSequence.svg?style=flat)](https://travis-ci.org/quells/DateSequence)
[![Version](https://img.shields.io/cocoapods/v/DateSequence.svg?style=flat)](https://cocoapods.org/pods/DateSequence)
[![License](https://img.shields.io/cocoapods/l/DateSequence.svg?style=flat)](https://cocoapods.org/pods/DateSequence)
[![Platform](https://img.shields.io/cocoapods/p/DateSequence.svg?style=flat)](https://cocoapods.org/pods/DateSequence)

## Example

To run the example tests, clone the repo, and run `pod install` from the Example directory first. Then open `DateSequence.xcworkspace` and run the tests in `DateSequence/Test/Tests.swift`.

```swift
// Bounded sequences
let dates = try! DateSequence(from: "2018-01-01", through: "2018-06-04", every: (7, .day))
// See also `DateSequence(from: to: every:)`

try! dates.contains("2018-03-05") // true

for d in dates {
    print(DashedISO8601DateFormatter.shared.string(from: d))
    // "2018-01-01", "2018-01-08", ...  "2018-06-04"
}
```

## Requirements

DateSequence requires iOS 10.0+ due to some nifty date arithmetic APIs added in that version.

## Installation

DateSequence is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DateSequence'
```

## License

DateSequence is available under the MIT license. See the LICENSE file for more info.
