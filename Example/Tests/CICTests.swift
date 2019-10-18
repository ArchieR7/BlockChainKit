//
//  CICTests.swift
//  BlockChainKit_Tests
//
//  Created by Archie on 2019/10/15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import BlockChainKit
import XCTest

class CICTests: XCTestCase {
    func testCIC() {
        let privateKey = "d03353d9ea60e4a2277c1fcf35b858a46c6f60001a8a5ddd32b48f234ee0b9ca"
        let publicKey = "04306fee9170764458c5e3faa223ee4d83dd4fb78bc4ca2d9c8900fb93a249763a039de50934307372ebcab41a45c3ecde8cd8b8383cad5a3e615c8fd7bb9c0136"
        XCTAssertEqual(CIC.publicKey(privateKey: privateKey), publicKey)
        let result = "32363731363736383930323934393434313839373735393932333631353637323930393537303039353637333431323633353630373337343932343230363033343534333032313234373633317835333535313032383239333035363537393532313631373639383330323435353839303039373431323433373232383236333531363533363134363634343339363236353937313538303434"
        signCIC(parameter: CIC.CICSignParameter(privateKey: "d03353d9ea60e4a2277c1fcf35b858a46c6f60001a8a5ddd32b48f234ee0b9ca",
                                                address: "cxf431130f518b149fed3d6dfb485741954ed4d2d1",
                                                balance: "100000000000000000",
                                                type: "cic",
                                                fee: "100000000000000000",
                                                nonce: "31",
                                                coin: "cic"), result: result)
    }
    
    func testTGC() {
        let result = "313037323032303834373830353732353738303034363930333535313839373035383030303836383835363133393135343233363038393738393533323631353735333134363532323838323837783535383337343630313636353932333434353633363433383935373336353634353133373338343832343731393732333733383131313434393436313932343638333439333132303531363931"
        signCIC(parameter: CIC.CICSignParameter(privateKey: "d03353d9ea60e4a2277c1fcf35b858a46c6f60001a8a5ddd32b48f234ee0b9ca",
                                                address: "f431130f518b149fed3d6dfb485741954ed4d2d1",
                                                balance: "100000000000000000",
                                                type: "tgc",
                                                fee: "100000000000000000",
                                                nonce: "7",
                                                coin: "tgc"), result: result)
    }
    
    func testCIC1() {
        let result = "3131333931323339343231373838333739333732353331323537393735363837323933343638353131333435323437353835313038353232333938363333323334373235313133373337373031377831343338303638393331313732343934343636383337363838363431343238333839363439373033323033323737373233303235393933373034353734393738303032383735353431313236"
        signCIC(parameter: CIC.CICSignParameter(privateKey: "d03353d9ea60e4a2277c1fcf35b858a46c6f60001a8a5ddd32b48f234ee0b9ca",
                                                address: "cxf431130f518b149fed3d6dfb485741954ed4d2d1",
                                                balance: "100000000000000000",
                                                type: "cic",
                                                fee: "100000000000000000",
                                                nonce: "32",
                                                coin: "ci1"), result: result)
    }
    
    private func signCIC(parameter: CIC.CICSignParameter, result: String) {
        let sign = CIC.sign(parameter: parameter)
        XCTAssertEqual(sign, result)
    }
    
    func testTxid() {
        print(CIC.message(parameter: CIC.CICSignParameter(privateKey: "d03353d9ea60e4a2277c1fcf35b858a46c6f60001a8a5ddd32b48f234ee0b9ca",
                                                    address: "cxf431130f518b149fed3d6dfb485741954ed4d2d1",
                                                    balance: "100000000000000000",
                                                    type: "cic",
                                                    fee: "100000000000000000",
                                                    nonce: "32",
                                                    coin: "ci1")).sha256())
    }
}
