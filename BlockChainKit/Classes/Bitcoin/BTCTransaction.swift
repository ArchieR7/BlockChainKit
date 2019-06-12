//
//  BTCTransaction.swift
//  BlockChainKit
//
//  Created by Archie on 2019/6/10.
//

import CryptoSwift
import Foundation
import secp256k1

public struct BTCTransaction {
    public let version: UInt32
    public var txInCount: VarInt { return VarInt(inputs.count) }
    public let inputs: [BTCTransactionInput]
    public var txOutCount: VarInt { return VarInt(outputs.count) }
    public let outputs: [BTCTransactionOutput]
    public let lockTime: UInt32
    public var serialzed: Data {
        var data = Data(version.UInt8ArrayLE)
        data.append(txInCount.serialized())
        data.append(contentsOf: inputs.flatMap { $0.serialized })
        data.append(txOutCount.serialized())
        data.append(contentsOf: outputs.flatMap { $0.serialized })
        data.append(Data(lockTime.UInt8ArrayLE))
        return data
    }
    public var txHash: Data { return serialzed.sha256().sha256() }
    public var txID: String { return Data(txHash.reversed()).toHexString() }

    public func signatureHash(for utxo: BTCTransactionOutput, inputIndex: Int) -> Data {
        let txin = inputs[inputIndex]
        var data = Data(version.UInt8ArrayLE)
        data.append(inputs.reduce(Data(), { $0 + $1.previousOutput.serialized }))
        data.append(inputs.reduce(Data(), { $0 + Data($1.sequence.UInt8ArrayLE) }))
        data.append(txin.previousOutput.serialized)
        data.append(utxo.scriptCode)
        data.append(Data(txin.sequence.UInt8ArrayLE))
        data.append(outputs.reduce(Data(), { $0 + $1.serialized }))
        data.append(Data(lockTime.UInt8ArrayLE))
        data.append(Data(UInt32(0x01).UInt8ArrayLE))
        return data.sha256().sha256()
    }
}

public struct BTCUnspentTransaction {
    public let output: BTCTransactionOutput
    public let outpoint: BTCTransactionOutPoint

    public init(txid: String, scriptPubKey: String, satoshis: Int64, vout: UInt32) {
        let lockingScript = Data(Array<UInt8>(hex: scriptPubKey))
        let txidData = Data(Array<UInt8>(hex: txid))
        let txHash = Data(txidData.reversed())
        output = BTCTransactionOutput(lockingScript: lockingScript, value: satoshis)
        outpoint = BTCTransactionOutPoint(hash: txHash, index: vout)
    }
}

public struct BTCUnsignedTransaction {
    public let tx: BTCTransaction
    public let utxos: [BTCUnspentTransaction]
}

public struct BTCTransactionInput {
    public let previousOutput: BTCTransactionOutPoint
    public let signatureScript: Data
    public let sequence: UInt32
    public var scriptLength: VarInt { return VarInt(signatureScript.count) }
    public var serialized: Data {
        var data = previousOutput.serialized
        data.append(scriptLength.data)
        data.append(signatureScript)
        data.append(Data(sequence.UInt8ArrayLE))
        return data
    }
}

public struct BTCTransactionOutput {
    public let lockingScript: Data
    public let value: Int64
    public var scriptLength: VarInt { return VarInt(lockingScript.count) }
    public var serialized: Data {
        var data = Data(value.UInt8ArrayLE)
        data.append(scriptLength.serialized())
        data.append(lockingScript)
        return data
    }
    public var scriptCode: Data {
        var data = scriptLength.serialized()
        data.append(lockingScript)
        return data
    }
}

public struct BTCTransactionOutPoint {
    public let hash: Data
    public let index: UInt32
    public var serialized: Data { return hash + Data(index.UInt8ArrayLE) }
}
