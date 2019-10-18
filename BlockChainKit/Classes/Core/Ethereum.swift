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
        let privateKeyData = Data(Array<UInt8>(hex: privateKey))
        let publicKeyData = HDNode.publicKey(privateKey: privateKeyData, isCompressed: false)
        let formattedData = publicKeyData.dropFirst()
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

    public enum ChainID {
        case zero, mainnet, morden, ropsten, rinkeby, goerli, kovan, custom(Int)
        
        var rawValue: Int {
            switch self {
            case .zero: return 0
            case .mainnet: return 1
            case .morden: return 2
            case .ropsten: return 3
            case .rinkeby: return 4
            case .goerli: return 5
            case .kovan: return 42
            case let .custom(int): return int
            }
        }
    }
}

public extension Ethereum {
    struct RawTransaction {
        let nonce, gasPrice, gasLimit, toAddress, value, data: String

        public init(nonce: String,
                    gasPrice: String,
                    gasLimit: String,
                    toAddress: String,
                    value: String,
                    contract: String? = nil) {
            self.nonce = nonce
            self.gasPrice = gasPrice
            self.gasLimit = gasLimit
            if let contract = contract {
                self.toAddress = contract
                let address = toAddress.replacingOccurrences(of: "0x", with: String())
                let amount = value.replacingOccurrences(of: "0x", with: String()).paddingLeft(size: 64)
                self.data = "a9059cbb000000000000000000000000" + address + amount
                self.value = String()
            } else {
                self.value = value
                self.toAddress = toAddress
                self.data = String()
            }
        }

        func encode(chainID: ChainID = .mainnet) throws -> Data {
            var encodeData = [Data(hex: nonce),
                              Data(hex: gasPrice),
                              Data(hex: gasLimit),
                              Data(hex: toAddress),
                              value.isEmpty ? Data([]) : Data(hex: value),
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

public extension String {
    func paddingLeft(size: Int) -> String {
        return Array(repeating: "0", count: size - count).joined() + self
    }
}
