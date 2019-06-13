//
//  BTCTransactionBuilder.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/29.
//

import Foundation

public enum BTCTransactionBuilder {


    public static func build(destinations: [(address: String, amount: UInt64)],
                             utxos: [BTCUnspentTransaction],
                             extendOutput: BTCTransactionOutput? = nil) throws -> BTCUnsignedTransaction {
        var outputs = destinations.map { arg -> BTCTransactionOutput in
            let (address, amount) = arg
            return BTCTransactionOutput(address: address, value: Int64(amount))
        }
        if let output = extendOutput {
            outputs.append(output)
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
