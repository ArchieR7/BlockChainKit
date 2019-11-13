//
//  CIC.swift
//  BlockChainKit
//
//  Created by Archie on 2019/10/15.
//

import BigInt
import CryptoSwift
import secp256k1

public enum CIC {
    public struct CICSignParameter {
        public let privateKey, address, balance, type, fee, nonce, coin: String
        
        public init(privateKey: String, address: String, balance: String, type: String, fee: String, nonce: String, coin: String) {
            self.privateKey = privateKey
            self.address = address
            self.balance = balance
            self.type = type
            self.fee = fee
            self.nonce = nonce
            self.coin = coin
        }
    }
    
    public static func sign(parameter: CICSignParameter) -> String {
        let messageBuilder = message(parameter: parameter)
        let message = messageBuilder.bytes
        var hash = SHA3(variant: .keccak256).calculate(for: message)
        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
            fatalError("secp256k1 context")
        }
        var signature = secp256k1_ecdsa_recoverable_signature()
        var secretKey = Data(Array<UInt8>(hex: parameter.privateKey)).bytes
        guard secp256k1_ecdsa_sign_recoverable(context, &signature, &hash, &secretKey, nil, nil) == 1 else {
            fatalError("secp256k1 ecdsa sign recoverable")
        }
        var output64 = Data(repeating: 0, count: 64).bytes
        var recid: Int32 = 0
        secp256k1_ecdsa_recoverable_signature_serialize_compact(context, &output64, &recid, &signature)
        guard recid == 0 || recid == 1 else { fatalError("recid") }
        let r = Array(output64[0..<32])
        let s = Array(output64[32..<64])
        let bigIntR = BigInt(r.toHexString(), radix: 16)?.description ?? String()
        let bigIntS = BigInt(s.toHexString(), radix: 16)?.description ?? String()
        secp256k1_context_destroy(context)
        return "\(bigIntR)x\(bigIntS)".bytes.toHexString()
    }
    
    public static func publicKey(privateKey: String) -> String {
        let privateKeyData = Data(Array<UInt8>(hex: privateKey))
        let publicKeyData = HDNode.publicKey(privateKey: privateKeyData, isCompressed: false)
        return publicKeyData.toHexString()
    }
    
    public static func message(parameter: CICSignParameter) -> String {
        func convertToHex(_ value: String) -> String {
            var hexValue: String
            if value.hasPrefix("0x") {
                hexValue = value
            } else {
                hexValue = String(format: "%llx", UInt64(value) ?? 0)
            }
            if hexValue.replacingOccurrences(of: "0x", with: String()).count % 2 == 1 {
                return "0\(hexValue.replacingOccurrences(of: "0x", with: String()))"
            } else {
                return hexValue.replacingOccurrences(of: "0x", with: String())
            }
        }

        let wx = "wx\(publicKey(privateKey: parameter.privateKey))"
        let gx = "gx00\(parameter.address[parameter.address.count - 40..<parameter.address.count])"
        let hx = "hx\(convertToHex(parameter.nonce).paddingLeft(size: 32))"
        let ix = "ix\(parameter.fee.paddingLeft(size: 32))"
        let kx = "kx\(parameter.type.paddingLeft(size: 8))"
        let token = parameter.coin.bytes.toHexString().paddingLeft(size: 8)
        let px = parameter.coin == parameter.type ? String() : "px000\(token)\(parameter.balance.paddingLeft(size: 32))"
        let lx = "lx000"
        let sx = px.isEmpty ? "sx\(parameter.balance.paddingLeft(size: 32))" : "sx00000000000000000000000000000000"
        let tx = "tx0000null"
        let result = "\(wx)\(gx)\(hx)\(ix)\(kx)\(px)\(lx)\(sx)\(tx)"
        return result
    }
}
