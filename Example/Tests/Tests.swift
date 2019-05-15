import XCTest
import BlockChainKit

class Tests: XCTestCase {
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
        var mnemonic = "scale current glide mimic okay offer hawk maple clump spice farm home"
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

    private func validate(_ mnemonic: String) {
        do {
            try Mnemonic.validate(mnemonic)
        } catch {
            XCTFail("⚠️ \(error) ⚠️")
        }
    }
}
