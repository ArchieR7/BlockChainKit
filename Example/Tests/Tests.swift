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

    func testAddress() {
        let privateKey = "a845740b6c77162297cf42734fe715f1abe90c6c2790a25b462e337cd33e931e"
        let address = "0x2d4D3E8Cb7148Bee113d2Ffb42a42f22E8143464"
        XCTAssertEqual(address, Ethereum.address(privateKey: privateKey))
        let BTCPrivateKey = "L4uDufSWBE7gpKoBpCFuJKvo2yxkuTVVVtgMPj8nFpbSVjAPuMEJ"
        let BTCAddress = "1gBMhAqrL3y1imMdEWbLN9PxjFo1bqNEE"
        XCTAssertEqual(BTCAddress, Bitcoin.address(privateKey: BTCPrivateKey)!)
    }

    func testRLP() {
        XCTAssertEqual(try! RLP.encode("dog").toHexString(), "83646f67")
    }

    func testETHSignature() {
        let privateKey = "e331b6d69882b4cb4ea581d88e0b604039a3de5967688d3dcffdd2270c0fd109"
        let privateKeyData = Data(hex: privateKey)
        let rawTransaction = Ethereum.RawTransaction(nonce: "0x6e",
                                                     gasPrice: "0x040000000000",
                                                     gasLimit: "0x060000",
                                                     toAddress: "0x85b7ca161C311d9A5f0077d5048CAdFace89a267",
                                                     value: "0x015950000000000000000000")
        let mainnet = """
f8726e86040000000000830600009485b7ca161c311d9a5f0077d5048cadface89a2678c01595000000000000000000080
25
a028c0f73a9c767bdce910c841ebdd58411694ddf8594441efd63d87ecb34a2105
a074be5b9687e18b5ca9e79a46ab989ff0bc597bc2ca3c38ffe9b491125f3283ca
""".replacingOccurrences(of: "\n", with: String())
        let defaultValue = """
f8726e86040000000000830600009485b7ca161c311d9a5f0077d5048cadface89a2678c01595000000000000000000080
1b
a03a17139284e3be77d1387093079684b28d8c6096837d516f124110e03ce3cb3a
a03230af37a970f1d4f85e7707c768ebd049ea5b4cf52d10cc524a2e26aea38998
""".replacingOccurrences(of: "\n", with: String())
        let defaultERC20 = """
f8ab6e860400000000008306000094b8c77482e45f1f44de1745f52c74426c631bdd52
80
b844a9059cbb
00000000000000000000000085b7ca161c311d9a5f0077d5048cadface89a267
0000000000000000000000000000000000000000015950000000000000000000
1c
a03677e9b261db83d81f6e50e8b37b59b3750b193ceed0fbc6488c10df077aca99
a05535d28c1487a531788ee59547a4085c8b8593f4e4f477954059ac87b3d717b2
""".replacingOccurrences(of: "\n", with: String())
        XCTAssertEqual(mainnet, try! rawTransaction.sign(privateKey: privateKeyData, chainID: .mainnet).toHexString())
        XCTAssertEqual(defaultValue, try! rawTransaction.sign(privateKey: privateKeyData, chainID: .zero).toHexString())
        let ERC20Transaction = Ethereum.RawTransaction(nonce: "0x6e",
                                                       gasPrice: "0x040000000000",
                                                       gasLimit: "0x060000",
                                                       toAddress: "0x85b7ca161C311d9A5f0077d5048CAdFace89a267",
                                                       value: "0x015950000000000000000000",
                                                       contract: "0xB8c77482e45F1F44dE1745F52C74426C631bDD52")
        XCTAssertEqual(defaultERC20,
                       try! ERC20Transaction.sign(privateKey: privateKeyData, chainID: .zero).toHexString())
    }

    func testPadding() {
        print("015950000000000000000000".paddingLeft(size: 64))
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
