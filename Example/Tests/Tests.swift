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
        let ethFirstPrivateKey = "0xa845740b6c77162297cf42734fe715f1abe90c6c2790a25b462e337cd33e931e"
        let btcFirstPrivateKey = "L4uDufSWBE7gpKoBpCFuJKvo2yxkuTVVVtgMPj8nFpbSVjAPuMEJ"
        let BTCAccountPrivateExtendedKey = """
xprv9yKtyeT5WHuvAjcJFVhSTKfNAazE7naS5t6rkXZdU6Q6Phj1wQxuPJFZAZzKhXkS5aSTBz1wMiSb3MSDCGPeGZN5N8ehy1oG4a64ZupRreX
"""
        let BTCAccountPublicExtendedKey = """
xpub6CKFP9yyLfUDPDgmMXESpTc6icpiXFJHT72TYuyF2Rw5GW4AUxH9w6a31sQebX5KPpmcKfm1AhMm4oqBGgmUNuHu9cnnufQ6YcuyPgx3NfX
"""
        let BTCBIP32PrivateExtendedKey = """
xprvA2HcWb32cTun7QqB61Wx1gy7pkUaoLcdHuB27yMFsfJZxm6AtcXKygpaT8xVCjvpZDug77oNhGq9fGEtW6tpqMqFtkkG4vD2YNJynhCGVc7
"""
        let BTCBIP32PublicExtendedKey = """
xpub6FGxv6ZvSqU5KtueC33xNpurNnK5CoLUf86cvMksRzqYqZRKS9qaXV94JQS1EB6j8hqiy951o9unZYfcGAf1X2txsBem3UYmN1Em8Xc9poF
"""
        let ETHAccountPrivateExtendedKey = """
xprv9xuFf1y5Tr8zn93FtRc7Wfd8XFKHFxmGYB1ot3GGwd5gXHoKeeRF4jR7LVH8h6XZi4zrQKqmCK8hHNSEb6fBX4S4zJrZ6DkVxEq5AQX8KLu
"""
        let ETHAccountPublicExtendedKey = """
xpub6Btc4XVyJDhHzd7izT97soZs5H9mfRV7uPwQgRftVxcfQ68UCBjVcXjbBkkBaJiSYTw1xX5Jb2Kf9y88sUyMVMMfDHW18Tn2mmVK5kBAo7W
"""
        let ETHBIP32PrivateExtendedKey = """
xprvA1hiqpmttrFrwat3TD2tTQpN8kXKNYSzkaj7iMeDn7qS9E97ChK1xYLoyMfeJnjYYEA4EYrXToPtncARSvykj56NT5AZwrvNb5uokw9xt8r
"""
        let ETHBIP32PublicExtendedKey = """
xpub6Eh5FLJnjDpAA4xWZEZtpYm6gnMon1Ar7oeiWk3qLTNR22UFkEdGWLfHpcTWBHYUGnfEjXAfdaTmeRCNv5A9ovCCxfkV2yCr9avcHZzNEMC
"""
        guard let privateExtendedKey = try? Base58.encode(node.privateExtendedKey()) else { return XCTFail() }
        XCTAssertEqual(privateExtendedKey, rootKey)
        let ETHAccount = node.derived(.hardened(44)).derived(.hardened(60)).derived(.hardened(0))
        XCTAssertEqual(try? Base58.encode(ETHAccount.privateExtendedKey()), ETHAccountPrivateExtendedKey)
        XCTAssertEqual(try? Base58.encode(ETHAccount.publicExtendedKey()), ETHAccountPublicExtendedKey)
        let ETHChain = ETHAccount.derived(.notHardened(0))
        XCTAssertEqual(try? Base58.encode(ETHChain.privateExtendedKey()), ETHBIP32PrivateExtendedKey)
        XCTAssertEqual(try? Base58.encode(ETHChain.publicExtendedKey()), ETHBIP32PublicExtendedKey)
        let ETH = ETHChain.derived(.notHardened(0))
        XCTAssertEqual(ethFirstPrivateKey, ETH.ethPrivateKey)
        let BTCAccount = node.derived(.hardened(44)).derived(.hardened(0)).derived(.hardened(0))
        XCTAssertEqual(try? Base58.encode(BTCAccount.privateExtendedKey()), BTCAccountPrivateExtendedKey)
        XCTAssertEqual(try? Base58.encode(BTCAccount.publicExtendedKey()), BTCAccountPublicExtendedKey)
        let BTCChain = BTCAccount.derived(.notHardened(0))
        let BTC = BTCChain.derived(.notHardened(0))
        XCTAssertEqual(try? Base58.encode(BTCChain.privateExtendedKey()), BTCBIP32PrivateExtendedKey)
        XCTAssertEqual(try? Base58.encode(BTCChain.publicExtendedKey()), BTCBIP32PublicExtendedKey)
        guard let BTCFirstPrivateKey = BTC.WIF() else { return XCTFail() }
        XCTAssertEqual(BTCFirstPrivateKey, btcFirstPrivateKey)
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
