# BlockChainKit

[![CI Status](https://img.shields.io/travis/Archie/BlockChainKit.svg?style=flat)](https://travis-ci.org/Archie/BlockChainKit)
[![Version](https://img.shields.io/cocoapods/v/BlockChainKit.svg?style=flat)](https://cocoapods.org/pods/BlockChainKit)
[![License](https://img.shields.io/cocoapods/l/BlockChainKit.svg?style=flat)](https://cocoapods.org/pods/BlockChainKit)
[![Platform](https://img.shields.io/cocoapods/p/BlockChainKit.svg?style=flat)](https://cocoapods.org/pods/BlockChainKit)

## Usage

### Create mnemonic
```swift
// default is 128 bytes to create mnemonic with 12 words 
let mnemonic = Mnemonic.create()

// create mnemonic with 15, 18, 21, 24 words by different strength
let mnemonicWith160Bytes = Mnemonic.create(strength: .words15)
let mnemonicWith192Bytes = Mnemonic.create(strength: .words18)
let mnemonicWith224Bytes = Mnemonic.create(strength: .words21)
let mnemonicWith256Bytes = Mnemonic.create(strength: .words24)
```

### Validate mnemonic
```
do {
    try Mnemonic.valdiate(mnemonic)
} catch {
    if let error = error as? MnemonicError {
        switch error {
            case .length: // length should be 12, 15, 18, 21, 24
            case .invalid: // validate mnemonic with check sum
            case .setUp: // with framework's issue (e.g wordlist)
            case let .words(words): // contains invalid words
        }
    }
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BlockChainKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BlockChainKit'
```

## Author

[Archie](https://twitter.com/ChangArchie), Archie@Archie.tw

## License

BlockChainKit is available under the MIT license. See the LICENSE file for more info.
