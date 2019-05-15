//
//  Mnemonic.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/14.
//

import Foundation
import CryptoSwift

public final class Mnemonic {
    public enum Strength: Int {
        case words12 = 128
        case words15 = 160
        case words18 = 192
        case words21 = 224
        case words24 = 256

        init?(wordCount: Int) {
            switch wordCount {
            case 12: self = .words12
            case 15: self = .words15
            case 18: self = .words18
            case 21: self = .words21
            case 24: self = .words24
            default: return nil
            }
        }

        var checkSumStrength: Int {
            switch self {
            case .words12: return 4
            case .words15: return 5
            case .words18: return 6
            case .words21: return 7
            case .words24: return 8
            }
        }
    }

    public static func create(strength: Strength = .words12, language: WordList = .English) -> String {
        let byteCount = strength.rawValue / 8
        var bytes = Data(count: byteCount)
        _ = bytes.withUnsafeMutableBytes { pointer -> Int32 in
            guard let baseAddress = pointer.baseAddress else { return 0 }
            return SecRandomCopyBytes(kSecRandomDefault, byteCount, baseAddress)
        }
        return create(entropy: bytes, language: language)
    }

    public static func create(entropy: Data, language: WordList = .English) -> String {
        let entropyBits = String(entropy.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let hashBits = String(entropy.sha256().flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checkSum = String(hashBits.prefix((entropy.count * 8) / 32))
        let words = language.words
        let concatenatedBits = entropyBits + checkSum
        var mnemonic = [String]()
        for index in 0..<(concatenatedBits.count / 11) {
            let wordIndex = Int(strtoul(String(concatenatedBits[index * 11..<index * 11 + 11]), nil, 2))
            mnemonic.append(String(words[wordIndex]))
        }
        return mnemonic.joined(separator: " ")
    }

    public static func validate(_ mnemonic: String, wordlist: WordList? = nil) throws {
        let mnemonicArray = mnemonic.split(separator: " ")
        guard let words = wordlist?.words ?? detectWordlist(mnemonic)?.words else {
            throw MnemonicError.setUp("Wordlist")
        }
        var invalidWords = [String]()
        mnemonicArray.forEach {
            let word = String($0)
            if words.contains(word) == false {
                invalidWords.append(word)
            }
        }
        guard invalidWords.isEmpty else { throw MnemonicError.words(invalidWords) }
        let entropy = mnemonicArray.compactMap {
            let word = String($0)
            if let index = words.firstIndex(of: word) {
                return pad(String(index, radix: 2), toSize: 11)
            } else {
                return nil
            }
        }.joined()
        guard let strength = Strength(wordCount: mnemonicArray.count) else { throw MnemonicError.length }
        let entropyHash = entropy[0..<strength.rawValue].split(by: 8).compactMap { Int($0, radix: 2) }.map { UInt8($0) }
        let checkSum = entropy[strength.rawValue..<entropy.count]
        guard let number = entropyHash.sha256().first else { throw MnemonicError.setUp("entropy hash") }
        guard pad(String(number, radix: 2), toSize: 8)[0..<strength.checkSumStrength] == checkSum else {
            throw MnemonicError.invalid
        }
    }

    private static func detectWordlist(_ text: String) -> WordList? {
        switch NSLinguisticTagger.dominantLanguage(for: text) {
        case "en": return .English
        case "ja": return .Japanese
        case "ko": return .Korean
        case "es": return .Spanish
        case "zh-Hans": return .SimpifiedChinese
        case "zh-Hant": return .TraditionalChinese
        case "fr": return .French
        case "it": return .Italian
        default: return nil
        }
    }

    private static func pad(_ text: String, toSize: Int) -> String {
        var padded = text
        for _ in 0..<(toSize - text.count) {
            padded = "0" + padded
        }
        return padded
    }
}

extension String {
    func split(by length: Int) -> [String] {
        var start = startIndex
        var results = [Substring]()
        while start < endIndex {
            let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
            results.append(self[start..<end])
            start = end
        }
        return results.map { String($0) }
    }
}

extension String {
    subscript (index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }

    subscript (index: Int) -> String {
        return String(self[index] as Character)
    }

    subscript (range: Range<Int>) -> String {
        return String(self[self.index(self.startIndex,
                                      offsetBy: range.lowerBound)..<self.index(self.startIndex,
                                                                               offsetBy: range.upperBound)])
    }
}


public enum MnemonicError: Error {
    case words([String]), invalid, setUp(String), length
}
