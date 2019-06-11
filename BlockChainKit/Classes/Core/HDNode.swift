//
//  HDNode.swift
//  BlockChainKit
//
//  Created by Archie on 2019/5/15.
//

import BigInt
import CryptoSwift
import secp256k1

public struct HDNode {
    public let privateKey: Data
    public let chainCode: Data
    public let seed: Data
    public let depth: UInt8
    public let fingerprint: Data
    public let index: UInt32
    public let parentFingerprint: Data?

    public var ethPrivateKey: String {
        return "0x" + privateKey.toHexString()
    }
    public func WIF(isCompressed: Bool = true) -> String? {
        var data: Data = Data([UInt8(0x80)])
        data += privateKey
        if isCompressed {
            data += Data([UInt8(0x01)])
        }
        data += data.sha256().sha256().prefix(4)
        return try? Base58.encode(data)
    }

    public init(seed: Data) {
        self.seed = seed
        let value = Crypto.HMACSHA512(key: "Bitcoin seed".data(using: .ascii)!, data: seed)
        privateKey = value[0..<32]
        chainCode = value[32..<64]
        depth = 0
        index = 0
        fingerprint = HDNode.fingerprint(publicKey: HDNode.publicKey(privateKey: privateKey))
        parentFingerprint = nil
    }

    public init(seed: Data, privateKey: Data, chainCode: Data, index: UInt32, depth: UInt8, fingerprint: Data) {
        self.seed = seed
        self.privateKey = privateKey
        self.chainCode = chainCode
        self.depth = depth
        self.index = index
        parentFingerprint = fingerprint
        self.fingerprint = HDNode.fingerprint(publicKey: HDNode.publicKey(privateKey: privateKey))
    }

    public func publicKey(isCompressed: Bool = true) -> Data {
        return HDNode.publicKey(privateKey: privateKey, isCompressed: isCompressed)
    }

    public func privateExtendedKey(version: UInt32 = KeyVersion.Private.mainnet.rawValue) -> Data {
        var result = version.UInt8ArrayBE
        result.append(depth)
        result.append(contentsOf: parentFingerprint?.bytes ?? [0, 0, 0, 0])
        result.append(contentsOf: index.UInt8ArrayLE)
        result.append(contentsOf: chainCode.bytes)
        result.append(0)
        result.append(contentsOf: privateKey.bytes)
        let checkSum = result.sha256().sha256()[0..<4]
        return Data(result + checkSum)
    }

    public func publicExtendedKey(version: UInt32 = KeyVersion.Public.mainnet.rawValue) -> Data {
        var result = version.UInt8ArrayBE
        result.append(depth)
        result.append(contentsOf: parentFingerprint?.bytes ?? [0, 0, 0, 0])
        result.append(contentsOf: index.UInt8ArrayLE)
        result.append(contentsOf: chainCode.bytes)
        result.append(contentsOf: publicKey().bytes)
        let checkSum = result.sha256().sha256()[0..<4]
        return Data(result + checkSum)
    }

    public static func publicKey(privateKey: Data, isCompressed: Bool = true) -> Data {
        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
            fatalError("secp256k1 context")
        }
        let privateKeyBytes = privateKey.bytes
        var publicKey = secp256k1_pubkey()

        guard secp256k1_ec_pubkey_create(context, &publicKey, privateKeyBytes) == 1 else {
            fatalError("secp256k1 ec public key create")
        }
        let size = isCompressed ? 33 : 65
        let serializedKey = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        var sizeT = size_t(size)
        let compressedKey = isCompressed ? UInt32(SECP256K1_EC_COMPRESSED) : UInt32(SECP256K1_EC_UNCOMPRESSED)
        guard secp256k1_ec_pubkey_serialize(context, serializedKey, &sizeT, &publicKey, compressedKey) == 1 else {
            fatalError("secp256k1 serialize")
        }
        secp256k1_context_destroy(context)
        let data = Data(bytes: serializedKey, count: size)
        free(serializedKey)
        return data
    }

    public static func fingerprint(publicKey: Data) -> Data {
        let identifier = RIPEMD160.hash(publicKey.sha256())
        return identifier[0..<4]
    }

    public func derived(_ node: DerivationNode) -> HDNode {
        let edge: UInt32 = 0x80000000
        var data = Data()
        switch node {
        case .hardened:
            data = Data([UInt8(0)])
            data += privateKey
        case .notHardened:
            data += publicKey()
        }
        let derivingIndex = CFSwapInt32BigToHost(node.hardens ? (edge | node.index) : node.index)
        data += Data(derivingIndex.UInt8ArrayLE)
        let digest = Crypto.HMACSHA512(key: chainCode, data: data)
        let factor = BigUInt(digest[0..<32])
        let derivedChainCode = digest[32..<64]
        let curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
        let derivedPrivateKey = ((BigUInt(privateKey) + factor) % curveOrder).serialize()
        return HDNode(seed: seed,
                      privateKey: derivedPrivateKey,
                      chainCode: derivedChainCode,
                      index: derivingIndex,
                      depth: depth + 1,
                      fingerprint: fingerprint)
    }
}

public enum KeyVersion {
    public enum Private: UInt32 {
        case mainnet = 0x0488ADE4
        case testnet = 0x04358394
    }

    public enum Public: UInt32 {
        case mainnet = 0x0488B21E
        case testnet = 0x043587CF
    }
}

public enum DerivationNode {
    case hardened(UInt32)
    case notHardened(UInt32)

    public var index: UInt32 {
        switch self {
        case let .hardened(index), let .notHardened(index): return index
        }
    }

    public var hardens: Bool {
        switch self {
        case .hardened: return true
        case .notHardened: return false
        }
    }
}

extension UInt64 {
    var UInt8ArrayLE: [UInt8] {
        return [0, 8, 16, 24, 32, 40, 48, 56].map { UInt8(self >> $0 & 0x00000000000000FF) }
    }
    var UInt8ArrayBE: [UInt8] {
        return [56, 48, 40, 32, 24, 16, 8, 0].map { UInt8(self >> $0 & 0x00000000000000FF) }
    }
}

extension UInt32 {
    var UInt8ArrayLE: [UInt8] {
        return [0, 8, 16, 24].map { UInt8(self >> $0 & 0x000000FF) }
    }
    var UInt8ArrayBE: [UInt8] {
        return [24, 16, 8, 0].map { UInt8(self >> $0 & 0x000000FF) }
    }
}

extension UInt16 {
    var UInt8ArrayLE: [UInt8] {
        return [0, 8].map { UInt8(self >> $0 & 0x00FF) }
    }
    var UInt8ArrayBE: [UInt8] {
        return [8, 0].map { UInt8(self >> $0 & 0x00FF) }
    }
}

extension Int64 {
    var UInt8ArrayLE: [UInt8] {
        return [0, 8, 16, 24, 32, 40, 48, 56].map { UInt8(self >> $0 & 0x00000000000000FF) }
    }
    var UInt8ArrayBE: [UInt8] {
        return [56, 48, 40, 32, 24, 16, 8, 0].map { UInt8(self >> $0 & 0x00000000000000FF) }
    }
}
