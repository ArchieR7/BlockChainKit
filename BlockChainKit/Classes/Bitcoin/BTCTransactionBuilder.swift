//
//  BTCTransactionBuilder.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/29.
//

import Foundation

public enum BTCTransactionBuilder {
    public static func lockingScript(address: String) -> Data {
        var data = Data([0x76, 0xa9, 0x14])
        let publicKey = try! Base58.decode(address).dropLast(4).dropFirst()
        data.append(publicKey)
        data.append(contentsOf: [0x88])
        data.append(contentsOf: [0xac])
        return data
    }

    public static func build(destinations: [(address: String, amount: UInt64)],
                             utxos: [BTCUnspentTransaction]) throws -> BTCUnsignedTransaction {
        let outputs = destinations.map { arg -> BTCTransactionOutput in
            let (address, amount) = arg
            return BTCTransactionOutput(lockingScript: lockingScript(address: address), value: Int64(amount))
        }
        let unsignedInputs = utxos.map {
            BTCTransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max)
        }
        let tx = BTCTransaction(version: 1, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
        return BTCUnsignedTransaction(tx: tx, utxos: utxos)
    }
}

enum TransactionBuildError: Error {
    case error(String)
}
