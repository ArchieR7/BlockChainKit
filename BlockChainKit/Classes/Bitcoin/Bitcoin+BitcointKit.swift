//
//  Bitcoin+BitcointKit.swift
//  BlockChainKit_Example
//
//  Created by Archie on 2019/5/31.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import struct BitcoinKit.PrivateKey
import struct BitcoinKit.LegacyAddress
import struct BitcoinKit.TransactionOutput
import struct BitcoinKit.TransactionOutPoint
import struct BitcoinKit.UnspentTransaction
import protocol BitcoinKit.Address
import enum BitcoinKit.PrivateKeyError
import Foundation

extension Bitcoin {
    public static func sign(from address: String,
                            to toAddress: String,
                            amount: UInt64,
                            unspentTransactions: [UnspentTransaction],
                            wif: String,
                            isCompressed: Bool = true) throws -> String {
        guard let privateKey = PrivateKey(wif: wif, isCompressed: isCompressed) else {
            throw PrivateKeyError.invalidFormat
        }
        let fromLegacyAddress = try LegacyAddress(address)
        let toLegacyAddress = try LegacyAddress(toAddress)
        let utxoSelector = StandardUtxoSelector()
        let transactionBuilder = BTCTransactionBuilder()
        let signer = StandardTransactionSigner()
        let (toSpend, fee) = try utxoSelector.select(from: unspentTransactions, targetValue: amount)
        let totalAmount = toSpend.sum()
        let change = totalAmount - amount - fee
        let destinations: [(Address, UInt64)] = [(toLegacyAddress, amount), (fromLegacyAddress, change)]
        let unsignedTx = try transactionBuilder.build(destinations: destinations, utxos: toSpend)
        let signedTx = try signer.sign(unsignedTx, with: [privateKey])
        return signedTx.serialized().hex
    }
}

public typealias UnspentTransaction = BitcoinKit.UnspentTransaction

public extension UnspentTransaction {
    init?(txid: String, scriptPubKey: String, satoshis: Int64, vout: UInt32) {
        guard let lockingScript = Data(hex: scriptPubKey), let txidData = Data(hex: String(txid)) else { return nil }
        let txHash: Data = Data(txidData.reversed())
        let output = TransactionOutput(value: satoshis, lockingScript: lockingScript)
        let outpoint = TransactionOutPoint(hash: txHash, index: vout)
        self.init(output: output, outpoint: outpoint)
    }
}

public extension BitcoinKit.PrivateKey {
    init?(wif: String, isCompressed: Bool) {
        guard let raw = Bitcoin.privateData(wif: wif) else { return nil }
        self.init(data: raw, network: .mainnetBTC, isPublicKeyCompressed: isCompressed)
    }
}

