//
//  Bitcoin.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/17.
//

import Foundation

public enum Bitcoin {
    public static func address(privateKey: String, isCompressed: Bool = true) -> String? {
        let prefix = Data([UInt8(0x00)])
        guard let WIFData = try? Base58.decode(privateKey) else { return nil }
        let privateKeyData = WIFData.dropFirst().dropLast(5)
        let publicKeyData = HDNode.publicKey(privateKey: privateKeyData, isCompressed: isCompressed)
        let payload = RIPEMD160.hash(publicKeyData.sha256())
        let checkSum = (prefix + payload).sha256().sha256().prefix(4)
        return try? Base58.encode(prefix + payload + checkSum)
    }
}
