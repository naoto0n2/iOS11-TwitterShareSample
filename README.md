# iOS11-TwitterShareSample
Twitter share sample with TwitterKit in iOS11

## Requirements

- Xcode 9.2
- Swift 4.0.2
- iOS 9.0 or later

## Installation
### 1. Install [TwitterKit](https://dev.twitter.com/twitterkit/ios/overview) via [CocoaPods](https://cocoapods.org/)

```
$ pod install
```

### 2. Install [Realm](https://github.com/realm/realm-cocoa) via [Carthage](https://github.com/Carthage/Carthage)

```
$ carthage bootstrap --platform iOS
```

### 3. Set your Twitter consumerKey and consumerSecret
#### info.plist
URL types -> URLSchemes
```
twitterkit-<consumerKey>
```

#### AppDelegate.swift
```swift
Twitters.shared.start(consumerKey: "yourConsumerKey", consumerSecret: "yourConsumerSecret")
```
