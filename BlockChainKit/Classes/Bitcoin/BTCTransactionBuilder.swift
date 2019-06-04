//
//  BTCTransactionBuilder.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/29.
//

import protocol BitcoinKit.Address
import class BitcoinKit.Script
import struct BitcoinKit.Transaction
import struct BitcoinKit.TransactionInput
import struct BitcoinKit.TransactionOutput
import struct BitcoinKit.UnsignedTransaction
import Foundation

public struct BTCTransactionBuilder: TransactionBuilder {
    public init() {}
    public func build(destinations: [(address: Address, amount: UInt64)], utxos: [UnspentTransaction]) throws -> UnsignedTransaction {
        let outputs = try destinations.map { (address: Address, amount: UInt64) -> TransactionOutput in
            guard let lockingScript = Script(address: address)?.data else {
                throw TransactionBuildError.error("Invalid address type")
            }
            return TransactionOutput(value: Int64(amount), lockingScript: lockingScript)
        }

        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
}

enum TransactionBuildError: Error {
    case error(String)
}

public protocol TransactionBuilder {
    func build(destinations: [(address: Address, amount: UInt64)], utxos: [UnspentTransaction]) throws -> UnsignedTransaction
}
