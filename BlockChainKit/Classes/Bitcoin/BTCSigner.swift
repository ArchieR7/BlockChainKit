public enum BTCSigner {
    public static func sign(_ unsigned: BTCUnsignedTransaction,
                            with keys: [Data],
                            isCompressed: Bool) throws -> BTCTransaction {
        var signingInputs: [BTCTransactionInput]
        var signingTransaction: BTCTransaction {
            let tx: BTCTransaction = unsigned.tx
            return BTCTransaction(version: tx.version,
                                  inputs: signingInputs,
                                  outputs: tx.outputs,
                                  lockTime: tx.lockTime)
        }
        signingInputs = unsigned.tx.inputs
        for (i, utxo) in unsigned.utxos.enumerated() {
            let pubkeyHash = utxo.output.lockingScript[3..<23]
            guard let key = keys.filter({
                RIPEMD160.hash(Bitcoin.publicKey(privateKey: $0, isCompressed: isCompressed).sha256()) == pubkeyHash
            }).first else { continue }
            let sighash = signingTransaction.signatureHash(for: utxo.output, inputIndex: i)
            let signature = Crypto.sign(key: sighash, data: key)
            let txin = signingInputs[i]
            let pubkey = Bitcoin.publicKey(privateKey: key, isCompressed: isCompressed)
            let result = unlocking(signature: signature, pubkey: pubkey)
            signingInputs[i] = BTCTransactionInput(previousOutput: txin.previousOutput,
                                                   signatureScript: result,
                                                   sequence: txin.sequence)
        }
        return signingTransaction
    }

    public static func unlocking(signature: Data, pubkey: Data) -> Data {
        var data = Data([UInt8(signature.count + 1)]) + signature + [0x01]
        data.append(contentsOf: [UInt8(pubkey.count)])
        data.append(pubkey)
        return data
    }
}
