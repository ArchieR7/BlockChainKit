//
//  EthereumTests.swift
//  BlockChainKit_Tests
//
//  Created by Archie on 2019/5/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import BlockChainKit
import XCTest

class EthereumTests: XCTestCase {
    func testAddress() {
        let privateKey = "a845740b6c77162297cf42734fe715f1abe90c6c2790a25b462e337cd33e931e"
        let address = "0x2d4D3E8Cb7148Bee113d2Ffb42a42f22E8143464"
        XCTAssertEqual(address, Ethereum.address(privateKey: privateKey))
    }

    func testSignature() {
        let privateKey = "a6ce2f4f2cf9cef4a6ea6d94c5b3100ea2a506cbfa9dcca46a67d36f6957a651"
        let privateKeyData = Data(Array<UInt8>(hex: privateKey))
        let rawTransaction = Ethereum.RawTransaction(nonce: "0xd",
                                                     gasPrice: "2000000000",
                                                     gasLimit: "120000",
                                                     toAddress: "0xf613dcf472eff3f96a5f4e2202d41cf725dedbf0",
                                                     value: "100000000000000000",
                                                     contract: "0x6454340896b9ae47921809de9035f4dadea3ac8b")

        let defaultValue = """
    f8a90d84773594008301d4c0946454340896b9ae47921809de9035f4dadea3ac8b80b844a9059cbb000000000000000000000000f613dcf472eff3f96a5f4e2202d41cf725dedbf0000000000000000000000000000000000000000000000000016345785d8a00001ca0c6135b7858188440186ff54ff1990b72ad7d75d7ee44b69454c94871d6c128dca07e7293eb3159584c4e44f5308d9c0315bd0a9e642263d6b964db1d04638f1852
    """.replacingOccurrences(of: "\n", with: String())
        let defualtRaw = try! rawTransaction.sign(privateKey: privateKeyData, chainID: .zero).toHexString()
        XCTAssertEqual(defaultValue, defualtRaw)
    }

    func testETHSignature() {
        let privateKey = "e331b6d69882b4cb4ea581d88e0b604039a3de5967688d3dcffdd2270c0fd109"
        let privateKeyData = Data(Array<UInt8>(hex: privateKey))
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
        let raw = try! rawTransaction.sign(privateKey: privateKeyData, chainID: .mainnet).toHexString()
        XCTAssertEqual(mainnet, raw)
        let defualtRaw = try! rawTransaction.sign(privateKey: privateKeyData, chainID: .zero).toHexString()
        XCTAssertEqual(defaultValue, defualtRaw)
        let ERC20Transaction = Ethereum.RawTransaction(nonce: "0x6e",
                                                       gasPrice: "0x040000000000",
                                                       gasLimit: "0x060000",
                                                       toAddress: "0x85b7ca161C311d9A5f0077d5048CAdFace89a267",
                                                       value: "0x015950000000000000000000",
                                                       contract: "0xB8c77482e45F1F44dE1745F52C74426C631bDD52")
        let raw2 = try! ERC20Transaction.sign(privateKey: privateKeyData, chainID: .zero).toHexString()
        XCTAssertEqual(defaultERC20, raw2)
        let gtxcTransaction = Ethereum.RawTransaction(nonce: "0xa",
                                                      gasPrice: "0xa",
                                                      gasLimit: "0xa",
                                                      toAddress: "f431130f518b149fed3d6dfb485741954ed4d2d1",
                                                      value: "0xa")
        let privateKeyData2 = Data(Array<UInt8>(hex: "d03353d9ea60e4a2277c1fcf35b858a46c6f60001a8a5ddd32b48f234ee0b9ca"))
        let raw3 = try! gtxcTransaction.sign(privateKey: privateKeyData2, chainID: .custom(10142241)).toHexString()
        let gtxcRawTx = "f8610a0a0a94f431130f518b149fed3d6dfb485741954ed4d2d10a808401358465a00ff4a8e0d0efcb1e33768b5a74ef6ae29adb68b0a97a6deb5b331e8aafd54550a00b56a75dca1a74121c80a71d9dec425dc76bf41ae1c72b0380cbc14c08bd2f82"
        XCTAssertEqual(gtxcRawTx, raw3)
    }
}
