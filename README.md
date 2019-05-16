# BlockChainKit

[![CI Status](https://img.shields.io/travis/Archie/BlockChainKit.svg?style=flat)](https://travis-ci.org/Archie/BlockChainKit)
[![Version](https://img.shields.io/cocoapods/v/BlockChainKit.svg?style=flat)](https://cocoapods.org/pods/BlockChainKit)
[![License](https://img.shields.io/cocoapods/l/BlockChainKit.svg?style=flat)](https://cocoapods.org/pods/BlockChainKit)
[![Platform](https://img.shields.io/cocoapods/p/BlockChainKit.svg?style=flat)](https://cocoapods.org/pods/BlockChainKit)

## 🔏 BlockChainKit 🔏
The BlockChainKit is a Swift library provides mnemonic generation and validation with 8 languages, and it implements `NSLinguisticTagger` to detect mnemonic language automatically that you do not need to set language 🌍.

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
```swift
do {
    try Mnemonic.valdiate(mnemonic)
} catch {
    if let error = error as? MnemonicError {
        switch error {
            case .length: // length should be 12, 15, 18, 21, 24
            case .invalid: // validate mnemonic with check sum
            case let .words(words): // contains invalid words
        }
    }
}

// valdiate with specific language
try Mnemonic.valdiate(mnemonic, wordlist: .English)
```

### Create seed from mnemonic
```swift
Mnemonic.createSeed(mnemonic).toHexString()
```

### Create private key and public key from seed
```swift
let node = HDNode(seed: seed)
let BIP32RootKey = node.privateExtendedKey()
```

### Base58 encode and decode
```swift
do {
    try Base58.encode(node.privateExtendedKey())
} catch {
    if let error = error as? BaseCodableError {
        switch error {
        case .decode: // decode error
        case .encode: // encode error
        }
    }
}
```

and it provides a protocol to implement encode or decode with specific base.

```swift
// you can create a new base with alphabet
struct Base58: BaseCodable {
    static let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
}
```

### Derived
```swift
// BTC - m/44'/0'/0'
let account = node.derived(.hardened(44)).derived(.hardened(0)).derived(.hardened(0))
// BTC - m/44'/0'/0'/0
let chain = account.derived(.notHardened(0))
// BTC - m/44'/0'/0'/0/0
let addressNode = chain.derived(.notHardened(0))
let BTCPrivateKey = addressNode.WIF() 

// ETH - m/44'/60'/0'/0/0
let ETHAccount = node.derived(.hardened(44)).derived(.hardened(60)).derived(.hardened(0))
let ETHPrivateKey = ETHAccount.derived(.notHardened(0)).derived(.notHardened(0)).ethPrivateKey
```

## Feature

- [X] BIP32
- [x] BIP39
- [X] BIP44

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Swift 5.0

## Installation

BlockChainKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BlockChainKit', '~> 0.1.1'
```

## Author

[Archie](https://twitter.com/ChangArchie), Archie@Archie.tw

## License

BlockChainKit is available under the MIT license. See the LICENSE file for more info.

## Reference

- RIPEMD160.swift - [HDWalletKit](https://github.com/yuzushioh/HDWalletKit)
