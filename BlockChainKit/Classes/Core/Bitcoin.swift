//
//  Bitcoin.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/17.
//

import Foundation

public enum Bitcoin {
    public static func privateData(wif: String) -> Data? {
        guard let WIFData = try? Base58.decode(wif) else { return nil }
        return WIFData.dropFirst().dropLast(5)
    }

    public static func publicKey(privateKey: Data, isCompressed: Bool) -> Data {
        return HDNode.publicKey(privateKey: privateKey, isCompressed: isCompressed)
    }

    public static func publicKey(wif: String, isCompressed: Bool) -> Data? {
        guard let privateKey = privateData(wif: wif) else { return nil }
        return publicKey(privateKey: privateKey, isCompressed: isCompressed)
    }

    public static func address(privateKey: String, isCompressed: Bool = true) -> String? {
        let prefix = Data([UInt8(0x00)])
        guard let publicKeyData = publicKey(wif: privateKey, isCompressed: isCompressed) else { return nil }
        let payload = RIPEMD160.hash(publicKeyData.sha256())
        let checkSum = (prefix + payload).sha256().sha256().prefix(4)
        return try? Base58.encode(prefix + payload + checkSum)
    }
}
