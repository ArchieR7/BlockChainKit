import XCTest
import BlockChainKit

class Tests: XCTestCase {
    private lazy var testMnemonic = "scale current glide mimic okay offer hawk maple clump spice farm home"
    private lazy var mnemonicWith128Bytes = Mnemonic.create()
    private lazy var mnemonicWith160Bytes = Mnemonic.create(strength: .words15)
    private lazy var mnemonicWith192Bytes = Mnemonic.create(strength: .words18)
    private lazy var mnemonicWith224Bytes = Mnemonic.create(strength: .words21)
    private lazy var mnemonicWith256Bytes = Mnemonic.create(strength: .words24)

    func testWordListCount() {
        XCTAssertEqual(WordList.English.words.count, 2048)
        XCTAssertEqual(WordList.French.words.count, 2048)
        XCTAssertEqual(WordList.Italian.words.count, 2048)
        XCTAssertEqual(WordList.Japanese.words.count, 2048)
        XCTAssertEqual(WordList.Korean.words.count, 2048)
        XCTAssertEqual(WordList.SimpifiedChinese.words.count, 2048)
        XCTAssertEqual(WordList.Spanish.words.count, 2048)
        XCTAssertEqual(WordList.TraditionalChinese.words.count, 2048)
    }

    func testValidateMnemonic() {
        var mnemonic = testMnemonic
        do {
            try Mnemonic.validate(mnemonic)
        } catch {
            XCTFail("⚠️ \(error) ⚠️")
        }
        mnemonic = "scale current glide mimic okay offer hawk maple clump spice farm home home"
        do {
            try Mnemonic.validate(mnemonic)
            XCTFail()
        } catch {
            guard let error = error as? MnemonicError else { return XCTFail() }
            switch error {
            case .length: return
            default: XCTFail()
            }
        }
        mnemonic = "scale current glide mimic okay offer hawk maple clump spice farmee homeee"
        do {
            try Mnemonic.validate(mnemonic)
            XCTFail()
        } catch {
            guard let error = error as? MnemonicError else { return XCTFail() }
            switch error {
            case let .words(words): XCTAssertEqual(words.count, 2)
            default: XCTFail()
            }
        }
        mnemonic = "scale current glide mimic okay offer hawk maple clump farm home spice"
        do {
            try Mnemonic.validate(mnemonic)
            XCTFail()
        } catch {
            guard let error = error as? MnemonicError else { return XCTFail() }
            switch error {
            case .invalid: return
            default: XCTFail()
            }
        }
        mnemonic = "scale current glide mimic okay offer hawk maple clump spice farm home"
        do {
            try Mnemonic.validate(mnemonic, wordlist: .Japanese)
            XCTFail()
        } catch {
            guard let error = error as? MnemonicError else { return XCTFail() }
            switch error {
            case .invalid: return
            default: XCTFail()
            }
        }
    }

    func testSeed() {
        let mnemonic = testMnemonic
        let seed = """
3bfb45bf050727cf2aa8f3033ba13649325ea53af91311787f91c59ca00d75fe
9e5efb8f2d2881c6739d3cec6502855b0e49c67e2c610293d2ecb147a665ad38
"""
        XCTAssertEqual(Mnemonic.createSeed(mnemonic).toHexString(), seed.replacingOccurrences(of: "\n", with: String()))
    }

    func testCreateMnemonic() {
        print("ℹ️ mnemonic: \(mnemonicWith128Bytes) ℹ️")
        validate(mnemonicWith128Bytes)
        print("ℹ️ mnemonic: \(mnemonicWith160Bytes) ℹ️")
        validate(mnemonicWith160Bytes)
        print("ℹ️ mnemonic: \(mnemonicWith192Bytes) ℹ️")
        validate(mnemonicWith192Bytes)
        print("ℹ️ mnemonic: \(mnemonicWith224Bytes) ℹ️")
        validate(mnemonicWith224Bytes)
        print("ℹ️ mnemonic: \(mnemonicWith256Bytes) ℹ️")
        validate(mnemonicWith256Bytes)
    }

    func testHDNode() {
        let seed = Mnemonic.createSeed(testMnemonic)
        let node = HDNode(seed: seed)
        let rootKey = """
xprv9s21ZrQH143K2cYgp2cYiPLz6jwGUq8GeEfd6JDEf4u2DFTnFvkSE5HHKCLFF65dkBqCZ7x5V2aCJDjhqAQz9fn4xuW2iCRBkcH1JAr5EXM
"""
        guard let privateExtendedKey = try? Base58.encode(node.privateExtendedKey()) else { return XCTFail() }
        XCTAssertEqual(privateExtendedKey, rootKey)
    }
}

extension Tests {
    private func validate(_ mnemonic: String) {
        do {
            try Mnemonic.validate(mnemonic)
        } catch {
            XCTFail("⚠️ \(error) ⚠️")
        }
    }
}
