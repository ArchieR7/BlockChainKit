//
//  Bitcoin+BitcointKit.swift
//  BlockChainKit_Example
//
//  Created by Archie on 2019/5/31.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

extension Bitcoin {
    public static func sign(from address: String,
                            to toAddress: String,
                            amount: UInt64,
                            unspentTransactions: [BTCUnspentTransaction],
                            wif: String,
                            isCompressed: Bool = true) throws -> String {
        let utxoSelector = StandardUtxoSelector()
        let (toSpend, fee) = try utxoSelector.select(from: unspentTransactions, targetValue: amount)
        let totalAmount = toSpend.sum()
        let change = totalAmount - amount - fee
        let destinations: [(String, UInt64)] = [(toAddress, amount), (address, change)]
        let unsignedTx = try BTCTransactionBuilder.build(destinations: destinations, utxos: toSpend)
        let privateKey = Bitcoin.privateData(wif: wif)!
        let signedTx = try BTCSigner.sign(unsignedTx, with: [privateKey], isCompressed: isCompressed)
        return signedTx.serialzed.toHexString()
    }
}
