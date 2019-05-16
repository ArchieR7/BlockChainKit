//
//  Ethereum.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/16.
//

import CryptoSwift

public enum Ethereum {
    public static func address(privateKey: String) -> String {
        let privateKeyData = Data(hex: privateKey)
        let publicKeyData = HDNode.publicKey(privateKey: privateKeyData, isCompressed: false)
        let formattedData = (Data(hex: "0x") + publicKeyData).dropFirst()
        let addressData = Data(bytes: SHA3(variant: .keccak256).calculate(for: formattedData.bytes)).suffix(20)
        return "0x" + EIP55(addressData)
    }

    static func EIP55(_ data: Data) -> String {
        let address = data.toHexString()
        let hashData = Data(bytes: SHA3(variant: .keccak256).calculate(for: address.data(using: .ascii)!.bytes))
        let hash = hashData.toHexString()
        return zip(address, hash).map {
            switch $0 {
            case ("0", _), ("1", _), ("2", _), ("3", _), ("4", _), ("5", _), ("6", _), ("7", _), ("8", _), ("9", _):
                return String($0.0)
            case (_, "8"), (_, "9"), (_, "a"), (_, "b"), (_, "c"), (_, "d"), (_, "e"), (_, "f"):
                return String($0.0).uppercased()
            default:
                return String($0.0).lowercased()
            }
        }.joined()
    }
}
