//
//  Ethereum.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/16.
//

import BigInt
import CryptoSwift
import secp256k1

public enum Ethereum {
    public static func address(privateKey: String) -> String {
        let privateKeyData = Data(hex: privateKey)
        let publicKeyData = HDNode.publicKey(privateKey: privateKeyData, isCompressed: false)
        let formattedData = (Data(hex: "0x") + publicKeyData).dropFirst()
        let addressData = Data(SHA3(variant: .keccak256).calculate(for: formattedData.bytes)).suffix(20)
        return "0x" + EIP55(addressData)
    }

    static func EIP55(_ data: Data) -> String {
        let address = data.toHexString()
        let hashData = Data(SHA3(variant: .keccak256).calculate(for: address.data(using: .ascii)!.bytes))
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

    public enum ChainID: Int {
        case zero = 0, mainnet, morden, ropsten, rinkeby, goerli
        case kovan = 42
    }
}

public extension Ethereum {
    struct RawTransaction {
        let nonce, gasPrice, gasLimit, toAddress, value, data: String

        public init(nonce: String, gasPrice: String, gasLimit: String, toAddress: String, value: String, data: String) {
            self.nonce = nonce
            self.gasPrice = gasPrice
            self.gasLimit = gasLimit
            self.toAddress = toAddress
            self.value = value
            self.data = data
        }

        func encode(chainID: ChainID = .mainnet) throws -> Data {
            var encodeData = [Data(hex: nonce),
                              Data(hex: gasPrice),
                              Data(hex: gasLimit),
                              Data(hex: toAddress),
                              Data(hex: value),
                              Data(hex: data)]
            if chainID.rawValue > 0 {
                encodeData.append(contentsOf:[Data([UInt8(chainID.rawValue)]), Data([]), Data([])])
            }
            return try RLP.encode(nestedArrayOfData: encodeData)
        }

        public func sign(privateKey: Data, chainID: ChainID = .mainnet) throws -> Data {
            var hash = SHA3(variant: .keccak256).calculate(for: try encode(chainID: chainID).bytes)
            guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
                fatalError("secp256k1 context")
            }
            var signature = secp256k1_ecdsa_recoverable_signature()
            var secretKey = privateKey.bytes
            guard secp256k1_ecdsa_sign_recoverable(context, &signature, &hash, &secretKey, nil, nil) == 1 else {
                fatalError("secp256k1 ecdsa sign recoverable")
            }
            var output64 = Data(repeating: 0, count: 64).bytes
            var recid: Int32 = 0
            secp256k1_ecdsa_recoverable_signature_serialize_compact(context, &output64, &recid, &signature)
            guard recid == 0 || recid == 1 else { fatalError("recid") }
            let v = (BigUInt(recid) + BigUInt(chainID.rawValue == 0 ? 27 : (35 + 2 * chainID.rawValue))).serialize()
            let r = Array(output64[0..<32])
            let s = Array(output64[32..<64])
            let encodeData = [Data(hex: nonce),
                              Data(hex: gasPrice),
                              Data(hex: gasLimit),
                              Data(hex: toAddress),
                              Data(hex: value),
                              Data(hex: data),
                              v,
                              Data(r),
                              Data(s)]
            secp256k1_context_destroy(context)
            return try RLP.encode(nestedArrayOfData: encodeData)
        }
    }
}
