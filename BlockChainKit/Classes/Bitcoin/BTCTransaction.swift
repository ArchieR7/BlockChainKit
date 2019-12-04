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
    public var serialized: Data {
        var data = Data(version.UInt8ArrayLE)
        data.append(txInCount.serialized())
        data.append(contentsOf: inputs.flatMap { $0.serialized })
        data.append(txOutCount.serialized())
        data.append(contentsOf: outputs.flatMap { $0.serialized })
        data.append(Data(lockTime.UInt8ArrayLE))
        return data
    }
    public var txHash: Data { return serialized.sha256().sha256() }
    public var txID: String { return Data(txHash.reversed()).toHexString() }

    public func signatureHash(for utxo: BTCTransactionOutput, inputIndex: Int) -> Data {
        guard inputIndex < inputs.count else {
            return Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)
        }
        let serializer = TransactionSignatureSerializer(tx: self, utxo: utxo, inputIndex: inputIndex)
        var data = serializer.serialize()
        data += UInt32(1).UInt8ArrayLE
        return data.sha256().sha256()
    }

    public init(version: UInt32, inputs: [BTCTransactionInput], outputs: [BTCTransactionOutput], lockTime: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
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

    public init(previousOutput: BTCTransactionOutPoint, signatureScript: Data, sequence: UInt32) {
        self.previousOutput = previousOutput
        self.signatureScript = signatureScript
        self.sequence = sequence
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

    public init(address: String, value: Int64) {
        self.lockingScript = BTCTransactionOutput.lockingScript(address: address)
        self.value = value
    }

    public init(lockingScript: Data, value: Int64) {
        self.lockingScript = lockingScript
        self.value = value
    }

    public init(opReturnAddress: String) {
        value = 0
        let addressData = Data(hex: opReturnAddress)
        var data = Data([0x6a, UInt8(addressData.count)])
        data.append(addressData)
        lockingScript = data
    }

    public static func lockingScript(address: String) -> Data {
        var data = Data([0x76, 0xa9, 0x14])
        let publicKey = try! Base58.decode(address).dropLast(4).dropFirst()
        data.append(publicKey)
        data.append(contentsOf: [0x88, 0xac])
        return data
    }
}

public struct BTCTransactionOutPoint {
    public let hash: Data
    public let index: UInt32
    public var serialized: Data { return hash + Data(index.UInt8ArrayLE) }

    public init(hash: Data, index: UInt32) {
        self.hash = hash
        self.index = index
    }
}

public struct TransactionSignatureSerializer {
    var tx: BTCTransaction
    var utxo: BTCTransactionOutput
    var inputIndex: Int

    internal func modifiedInput(for i: Int) -> BTCTransactionInput {
        let txin = tx.inputs[i]
        let sigScript: Data
        let sequence: UInt32

        if i == inputIndex {
            sigScript = utxo.lockingScript
            sequence = txin.sequence
        } else {
            sigScript = Data()
            sequence = txin.sequence
        }
        return BTCTransactionInput(previousOutput: txin.previousOutput, signatureScript: sigScript, sequence: sequence)
    }

    public func serialize() -> Data {
        let inputsToSerialize: [BTCTransactionInput]
        let outputsToSerialize: [BTCTransactionOutput]
        inputsToSerialize = (0..<tx.inputs.count).map { modifiedInput(for: $0) }
        outputsToSerialize = tx.outputs

        let tmp = BTCTransaction(version: tx.version,
                                 inputs: inputsToSerialize,
                                 outputs: outputsToSerialize,
                                 lockTime: tx.lockTime)
        return tmp.serialized
    }
}
